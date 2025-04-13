import xarray as xr
import numpy as np
from numcodecs import Blosc
import os
import sys
import logging
from typing import List, Dict

DATASET_CONFIG = {
    "dynamics": {"variables": ["precip", "pet", "temp"], "reshape_type": "dynamic"},
    "statics": {"variables": ["thetaS", "thetaR"], "reshape_type": "static"},
    "targets": {"variables": ["vwc", "actevap"], "reshape_type": "target"},
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

def write_to_zarr(dataset: xr.DataArray, output_path: str, group: str, compressor: Blosc):
    """Write the dataset to a Zarr file."""
    dataset.attrs.pop("_FillValue", None)  # Remove problematic attributes
    dataset.to_zarr(
        store=output_path,
        group=group,
        mode="a",
        encoding={var: {"compressor": compressor} for var in dataset.data_vars},
    )
    logger.info(f"Written {group} to {output_path}")

def process_and_convert_to_zarr(
    datasets: Dict[str, str], zarr_output_path: str, compressor: Blosc
):
    """Process and convert multiple datasets to Zarr."""
    for dataset_name, dataset_path in datasets.items():
        logger.info(f"Processing {dataset_name} from {dataset_path}")
        if not os.path.isfile(dataset_path):
            logger.error(f"{dataset_name.upper()} Error: Path is not a file {dataset_path}")
            continue

        try:
            dataset = xr.open_dataset(dataset_path)
            config = DATASET_CONFIG[dataset_name]
            if not validate_dataset(dataset, config["variables"], dataset_name):
                continue

            reshaped_dataset = reshape_dataset(dataset, config["reshape_type"])
            write_to_zarr(reshaped_dataset, zarr_output_path, dataset_name, compressor)
        except Exception as e:
            logger.error(f"{dataset_name.upper()} Error: {e}")

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

    compressor = Blosc(cname="zl4", clevel=3, shuffle=Blosc.BITSHUFFLE)

    datasets = {
        "dynamics": dynamics_path,
        "statics": statics_path,
        "targets": targets_path,
    }
    process_and_convert_to_zarr(datasets, zarr_output_path, compressor)

    logger.info("Conversion to Zarr completed successfully!")

if __name__ == "__main__":
    main()