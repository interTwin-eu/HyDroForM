import json
import logging
import os
import sys
import uuid
from typing import Dict, List

import numpy as np
import requests
import xarray as xr
from numcodecs import Blosc
from raster2stac import Raster2STAC

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler()],
)
logger = logging.getLogger(__name__)

UUID = str(uuid.uuid4())
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
STAC_API_URL = "https://stac.intertwin.fedcloud.eu/collections/"

if not AWS_ACCESS_KEY_ID or not AWS_SECRET_ACCESS_KEY:
    raise ValueError(
        "AWS_ACCESS_KEY and AWS_SECRET_KEY environment variables must be set"
    )
else:
    logger.info("AWS_ACCESS_KEY and AWS_SECRET_KEY environment variables are set")
    logger.info(f"AWS_ACCESS_KEY: {AWS_ACCESS_KEY_ID}")
    logger.info(f"AWS_SECRET_KEY: {AWS_SECRET_ACCESS_KEY}")


DATASET_CONFIG = {
    "dynamics": {"variables": ["precip", "pet", "temp"]},
    "statics": {"variables": ["thetaR", "KsatVer", "c"]},
    "targets": {"variables": ["vwc", "actevap"]},
}

logger.info(f"UUID UUID UUID: {UUID}")


def validate_dataset(
    dataset: xr.Dataset, expected_vars: List[str], dataset_name: str
) -> bool:
    """Validate that the dataset contains the expected variables."""
    missing_vars = [var for var in expected_vars if var not in dataset.variables]
    if missing_vars:
        logger.error(f"{dataset_name.upper()} Error: Missing variables {missing_vars}")
        return False
    logger.info(f"{dataset_name.capitalize()} variables: {list(dataset.variables)}")
    return True


def unpack_soil_layers(
    dataset, dataset_name, soil_layers: List[int], variable
) -> List[int]:
    if len(soil_layers) == 1:
        dataset = dataset.sel(layer=soil_layers).squeeze("layer")
    else:
        layers = range(len(soil_layers))
        for sl in layers:
            dataset[f"{variable}{sl}"] = (
                dataset[variable].isel(layer=sl, drop=True).rename(f"variable{sl + 1}")
            )
        dataset = dataset.drop_vars(variable)
    return dataset


def prepare_dataset(dataset: xr.Dataset, dataset_name, soil_layers=[1]) -> xr.Dataset:
    if dataset_name == "targets":
        # ! Wflow produces netcdf with lat flipped
        dataset.isel(lat=slice(None, None, -1))

    if dataset_name == "dynamics" or dataset_name == "statics":
        dataset = dataset.rename_dims({"latitude": "lat", "longitude": "lon"})
        try:
            dataset = dataset.rename_vars({"latitude": "lat", "longitude": "lon"})
        except BaseException:
            pass
    # Remove the layer dimension and create new variable for each soil layer
    # TODO: The variable parameter is hardcoded here for statics and dynamics.
    if dataset_name == "statics":
        logger.info(f"Unpacking and removing soil layer for {dataset_name}")
        dataset = unpack_soil_layers(dataset, dataset_name, soil_layers, variable="c")
    elif dataset_name == "targets":
        logger.info(f"Unpacking and removing soil layer for {dataset_name}")
        dataset = unpack_soil_layers(dataset, dataset_name, soil_layers, variable="vwc")

    # if dataset_name == "statics":
    # dataset = dataset.drop_dims("time")

    # Convert to float32
    dataset = dataset.apply(
        lambda x: x.astype(np.float32) if x.dtype == np.float64 else x
    )

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
                masks.append(
                    (dataset[mask] > 0).astype(np.bool_).rename(mask_rename[i])
                )
            except BaseException:
                # wflow_lakeareas is not in the dataset if domain is too small and there
                # are no lakes
                mask_rename.pop(1)
                mask_from_static.pop(1)
    das = []
    for (
        mask,
        name,
    ) in zip(masks, mask_rename):
        das.append(mask.rename(name))

    return (
        xr.merge(das)
        .to_dataarray(dim="mask_layer", name="mask")
        .to_dataset(dim="mask_layer")
    )


def write_to_zarr(dataset: xr.DataArray, output_path: str, name: str):
    """Write the dataset to a Zarr file."""
    dataset.attrs.pop("_FillValue", None)  # Remove problematic attributes
    filename = f"{output_path}/{name}.zarr"
    dataset.to_zarr(
        store=filename,
        # group=group,
        mode="w",
    )
    logger.info(f"Written {name} to {output_path}")


def process_and_convert(
    datasets: Dict[str, str],
    zarr_output_path: str,
):
    """Process and convert multiple datasets to Zarr."""
    PROCESSED = {}
    for dataset_name, dataset_path in datasets.items():
        logger.info(f"Processing {dataset_name} from {dataset_path}")
        if not os.path.isfile(dataset_path):
            logger.error(
                f"{dataset_name.upper()} Error: Path is not a file {dataset_path}"
            )
            continue
        try:
            dataset = xr.open_dataset(dataset_path)
            dataset = prepare_dataset(dataset, dataset_name, soil_layers=[1])
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

    return dynamics_merged, statics_merged


def process_to_stac(
    AWS_ACCESS_KEY_ID: str,
    AWS_SECRET_ACCESS_KEY: str,
    dataset: xr.Dataset,
    collection_id: str,
    output_path: str,
):
    """Process the datasets and convert them to STAC format.

    params:
        statics (xr.Dataset): The static dataset.
        dynamics (xr.Dataset): The dynamic dataset.
        targets (xr.Dataset): The target dataset.
        output_path (str): The output path for the STAC collection.

    returns:
    """
    logger.info("Executing Raster2STAC with Zarr conversion")
    logger.info(f"Input datasets: {dataset}")
    logger.info(f"Output path: {output_path}")

    try:
        r2s = Raster2STAC(data=dataset,
                          collection_id=f"{UUID}_{collection_id}",
                          collection_url=STAC_API_URL,
                          output_folder=output_path,
                          description="WFLOW output",
                          title=f"WFLOW output collection_{collection_id}",
                          ignore_warns=False,
                          keywords=["intertwin",
                                    "climate"],
                          links=[{"rel": "license",
                                  "href": "https://cds.climate.copernicus.eu/api/v2/terms/static/licence-to-use-copernicus-products.pdf",
                                  "title": "License to use Copernicus Products",
                                  },
                                 ],
                          providers=[{"url": "https://cds.climate.copernicus.eu/cdsapp#!/dataset/10.24381/cds.622a565a",
                                      "name": "Copernicus",
                                      "roles": ["producer"],
                                      },
                                     {"url": "https://cds.climate.copernicus.eu/cdsapp#!/dataset/10.24381/cds.622a565a",
                                      "name": "Copernicus",
                                      "roles": ["licensor"],
                                      },
                                     {"url": "https://cds.climate.copernicus.eu/cdsapp#!/dataset/10.24381/cds.622a565a",
                                      "name": "Copernicus",
                                      "roles": ["licensor"],
                                      },
                                     {"url": "http://www.eurac.edu",
                                      "name": "Eurac Research - Institute for Earth Observation",
                                      "roles": ["host"],
                                      },
                                     ],
                          stac_version="1.0.0",
                          s3_upload=True,
                          s3_endpoint_url="https://objectstore.eodc.eu:2222",
                          bucket_file_prefix=f"interTwin_EURAC/hydroform/wflow/{UUID}_",
                          bucket_name="rucio",
                          aws_access_key=AWS_ACCESS_KEY_ID,
                          aws_secret_key=AWS_SECRET_ACCESS_KEY,
                          version=None,
                          license="proprietary",
                          write_collection_assets=True,
                          )
    except Exception as e:
        logger.error(f"Raster2STAC Error: {e}")
        return 1
    logger.info("Raster2STAC initialized successfully")
    logger.info("Generating STAC collection")

    r2s.generate_zarr_stac(item_id=f"{collection_id}")

    logger.info("STAC collection generated successfully")
    logger.info(f"Uploading STAC collection to {r2s.collection_url}")

    try:
        with open(f"{output_path}/{r2s.collection_id}.json", "r") as f:
            stac_collection_to_post = json.load(f)
            requests.post(r2s.collection_url, json=stac_collection_to_post)
            stac_items = []
            with open(f"{output_path}/inline_items.csv", "r") as f:
                stac_items = f.readlines()
                for it in stac_items:
                    stac_data_to_post = json.loads(it)
                    requests.post(
                        f"{STAC_API_URL}/{r2s.collection_id}/items",
                        json=stac_data_to_post,
                    )
    except Exception as e:
        logger.error(f"STAC collection upload Error: {e}")
        return 1

    logger.info("STAC collection uploaded successfully")


def main():
    if len(sys.argv) < 5:
        logger.error(
            "Usage: python to_zarr.py <dynamics_path> <statics_path> <targets_path> <zarr_output_path>"
        )
        sys.exit(1)

    # Input paths
    dynamics_path = sys.argv[1]
    statics_path = sys.argv[2]
    targets_path = sys.argv[3]
    zarr_output_path = sys.argv[4]

    os.makedirs(zarr_output_path, exist_ok=True)

    datasets = {
        "dynamics": dynamics_path,
        "statics": statics_path,
        "targets": targets_path,
    }

    logger.info(f"WE ARE ABOUT TO PROCESS WOO")

    try:
        dynamics, statics = process_and_convert(
            datasets,
            zarr_output_path,
        )
    except Exception as e:
        logger.error(f"Error processing datasets: {e}")
        sys.exit(1)

    logger.info(f" USING UUID: {UUID}")

    datasets_to_stac = {
        "dynamics": dynamics,
        "statics": statics,
    }

    logger.info("Processing datasets to STAC")

    for name, dataset in datasets_to_stac.items():
        logger.info(f"Processing {name} ({type(dataset)})")
        process_to_stac(
            AWS_ACCESS_KEY_ID,
            AWS_SECRET_ACCESS_KEY,
            dataset,
            output_path=zarr_output_path,
            collection_id=f"wflow_output_{name}",
        )
        logger.info(f"Collection {name} can be found at {
            STAC_API_URL}{UUID}_wflow_output_{name}")
    logger.info("Processing and conversion to Zarr completed successfully!")


if __name__ == "__main__":
    main()
