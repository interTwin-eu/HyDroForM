import xarray as xr
import numpy as np
from numcodecs import Blosc
import os
import sys
import logging
from typing import List, Dict

DATASET_CONFIG = {
    "dynamics": {"variables": ["precip", "pet", "temp"]},
    "statics": {"variables": ["thetaR", "KsatVer", "c"]},
    "targets": {"variables": ["vwc", "actevap"]},
}

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler()],
)
logger = logging.getLogger(__name__)

def validate_dataset(dataset: xr.Dataset, expected_vars: List[str], dataset_name: str) -> bool:
    """Validate that the dataset contains the expected variables."""
    missing_vars = [var for var in expected_vars if var not in dataset.variables]
    if missing_vars:
        logger.error(f"{dataset_name.upper()} Error: Missing variables {missing_vars}")
        return False
    logger.info(f"{dataset_name.capitalize()} variables: {list(dataset.variables)}")
    return True


def unpack_soil_layers(dataset, dataset_name, soil_layers: List[int], variable) -> List[int]:
    if len(soil_layers) == 1:
        dataset = dataset.sel(layer=soil_layers).squeeze("layer")
    else:
        layers = range(len(soil_layers))
        for sl in layers:
            dataset[f"{variable}{sl}"] = dataset[variable].isel(layer=sl, drop=True).rename(f"variable{sl + 1}")
        dataset = dataset.drop_vars(variable)
    return dataset

def prepare_dataset(dataset: xr.Dataset, dataset_name, soil_layers = [1]) -> xr.Dataset:
    if dataset_name == "targets":
        # ! Wflow produces netcdf with lat flipped
        dataset = dataset.isel(lat=slice(None, None, -1))
    
    if dataset_name == "dynamics" or dataset_name == "statics":
        dataset = dataset.rename_dims({"latitude":"lat", "longitude":"lon"})
        try:
            dataset = dataset.rename_vars({"latitude":"lat", "longitude":"lon"})
        except:
            pass
    # Remove the layer dimension and create new variable for each soil layer
    # TODO: The variable parameter is hardcoded here for statics and dynamics.  
    if dataset_name == "statics":
        logger.info(f"Unpacking and removing soil layer for {dataset_name}")
        dataset = unpack_soil_layers(dataset, dataset_name, soil_layers, variable = "c")
    elif dataset_name == "targets":
        logger.info(f"Unpacking and removing soil layer for {dataset_name}")
        dataset = unpack_soil_layers(dataset, dataset_name, soil_layers, variable = "vwc")
    
    if dataset_name == "statics":
        dataset = dataset.drop_dims("time")
   
    # Convert to float32 
    dataset = dataset.apply(lambda x: x.astype(np.float32) if x.dtype == np.float64 else x)
    
    # Remove attributes that is not serializable
    dataset.attrs.pop("_FillValue", None)

    return dataset

def generate_mask(dataset):
    mask_from_static = ["thetaS", "wflow_lakeareas"]
    mask_rename = ["mask_missing", "mask_lake"]
    masks = []

    for i, mask in enumerate(mask_from_static):
        if i == 0:
            masks.append(np.isnan(dataset[mask]).rename(mask_rename[i]))
        else:
            try:
                masks.append((dataset[mask] > 0).astype(np.bool_).rename(mask_rename[i]))
            except:
                # wflow_lakeareas is not in the dataset if domain is too small and there are no lakes
                mask_rename.pop(1)
                mask_from_static.pop(1)
    das = []
    for (
        mask,
        name,
    ) in zip(masks, mask_rename):
        das.append(mask.rename(name))

    return xr.merge(das).to_dataarray(dim="mask_layer", name="mask").to_dataset(dim="mask_layer")

def reshape_dataset(dataset: xr.Dataset, reshape_type: str) -> xr.DataArray:
    """Reshape the dataset based on its type."""
    if reshape_type == "dynamic":
        return (
            dataset.to_array(dim="feat")
            .stack(gridcell=["lat", "lon"])
            .transpose("gridcell", "time", "feat")
        )
    elif reshape_type == "static":
        return (
            dataset.drop_vars("spatial_ref", errors="ignore")
            .to_array(dim="feat")
            .stack(gridcell=["lat", "lon"])
            .transpose("gridcell", "feat")
        )
    elif reshape_type == "target":
        return (
            dataset.to_array(dim="feat")
            .stack(gridcell=["lat", "lon"])
            .transpose("gridcell", "time", "feat")
        )
    else:
        raise ValueError(f"Unknown reshape type: {reshape_type}")

def write_to_zarr(dataset: xr.DataArray, output_path: str,name: str, compressor: Blosc):
    """Write the dataset to a Zarr file."""
    dataset.attrs.pop("_FillValue", None)  # Remove problematic attributes
    filename = f"{output_path}/{name}.zarr"
    dataset.to_zarr(
        store=filename,
        #group=group,
        mode="w",
        encoding={var: {"compressor": compressor} for var in dataset.data_vars},
    )
    logger.info(f"Written {name} to {output_path}")

def process_and_convert_to_zarr(
    datasets: Dict[str, str], zarr_output_path: str, compressor: Blosc
):
    """Process and convert multiple datasets to Zarr."""
    PROCESSED = {}
    for dataset_name, dataset_path in datasets.items():
        logger.info(f"Processing {dataset_name} from {dataset_path}")
        if not os.path.isfile(dataset_path):
            logger.error(f"{dataset_name.upper()} Error: Path is not a file {dataset_path}")
            continue
        try:
            dataset = xr.open_dataset(dataset_path)
            dataset = prepare_dataset(dataset, dataset_name, soil_layers= [1])
            if dataset_name == "statics":

                mask = generate_mask(dataset)
                PROCESSED["mask"] = mask
            config = DATASET_CONFIG[dataset_name]
            if not validate_dataset(dataset, config["variables"], dataset_name):
                continue
            PROCESSED[dataset_name] = dataset
        except Exception as e:
            logger.error(f"{dataset_name.upper()} Error: {e}")


    # TODO: Subset dynamics time to targets time 
    PROCESSED["dynamics"] = PROCESSED["dynamics"].sel(time=PROCESSED["targets"].time)

    dynamics_merged = xr.merge([PROCESSED["dynamics"], PROCESSED["targets"]])
    statics_merged = xr.merge([PROCESSED["statics"], PROCESSED["mask"]])

    write_to_zarr(dynamics_merged, zarr_output_path, "dynamics", compressor)
    write_to_zarr(statics_merged, zarr_output_path, "statics", compressor)

def main():
    if len(sys.argv) < 5:
        logger.error("Usage: python to_zarr.py <dynamics_path> <statics_path> <targets_path> <zarr_output_path>")
        sys.exit(1)

    # Input paths
    dynamics_path = sys.argv[1]
    statics_path = sys.argv[2]
    targets_path = sys.argv[3]
    zarr_output_path = sys.argv[4]

    os.makedirs(zarr_output_path, exist_ok=True)

    compressor = Blosc(cname="lz4", clevel=4, shuffle=Blosc.BITSHUFFLE)

    datasets = {
        "dynamics": dynamics_path,
        "statics": statics_path,
        "targets": targets_path,
    }
    process_and_convert_to_zarr(datasets, zarr_output_path, compressor)

    logger.info("Conversion to Zarr completed successfully!")

if __name__ == "__main__":
    main()