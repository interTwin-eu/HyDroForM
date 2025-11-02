"""

python wflow2hython.py "/path/to/input/dir" "/path/to/output/dir"

python3 to_zarr.py /home/jzvolensky/eurac/projects/TEMP/HyDroForM/openeo/wflow/wflow-output/37r0fevz/model/forcings.nc \
      /home/jzvolensky/eurac/projects/TEMP/HyDroForM/openeo/wflow/wflow-output/37r0fevz/model/staticmaps.nc \
      /home/jzvolensky/eurac/projects/TEMP/HyDroForM/openeo/wflow/wflow-output/37r0fevz/run_default/output.nc \
      /home/jzvolensky/eurac/projects/TEMP/HyDroForM/workflows/surrogate

"""

import logging
import os
import sys
from typing import List

import numpy as np
import xarray as xr
from hython.io import read_from_zarr, write_to_zarr
from hython.preprocessor import reshape
from hython.utils import build_mask_dataarray
from numcodecs import Blosc

OUTPUT_NAME: str = "demo"

DYNAMIC: List[str] = ["precip", "pet", "temp"]
STATIC: List[str] = ["thetaS", "thetaR"]
TARGET: List[str] = ["vwc", "actevap"]
MASK_FROM_STATIC: List[str] = ["thetaS"]
RENAME_MASK: List[str] = ["mask_missing"]

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler()],
)

logger = logging.getLogger(__name__)


def main(
    dynamics: xr.Dataset,
    statics: xr.Dataset,
    targets: xr.Dataset,
    zarr_output_path: str,
) -> None:
    """
    Convert HydroMT/Wflow outputs to Zarr format

    Parameters
    ----------
    dynamics : xarray.Dataset
        Dataset containing the dynamic variables
    statics : xarray.Dataset
        Dataset containing the static variables
    targets : xarray.Dataset
        Dataset containing the target variables
    zarr_output_path : str
        Path to output zarr file

    Returns
    -------
    None
    """

    logger.info("Renaming variables to match the expected names")

    try:
        dynamics = dynamics.rename({"latitude": "lat", "longitude": "lon"})
        statics = statics.rename({"latitude": "lat", "longitude": "lon"})
    except BaseException:
        pass

    logger.info("Reversing latitude dimension")

    targets = targets.isel(lat=slice(None, None, -1)).sel(layer=1)
    statics = statics.sel(layer=1)

    logger.info("Building masks")

    masks = []
    for i, mask in enumerate(MASK_FROM_STATIC):
        if i == 0:
            masks.append(np.isnan(statics[mask]).rename(RENAME_MASK[i]))
        else:
            masks.append((statics[mask] > 0).astype(np.bool_).rename(RENAME_MASK[i]))

    masks = build_mask_dataarray(masks, names=RENAME_MASK)

    logger.info("Reshaping and writing to zarr")

    Xd = reshape(dynamics, "dynamic", return_type="xarray")
    Xs = reshape(statics.drop_dims("time"), "static", return_type="xarray")
    Y = reshape(targets, "target", return_type="xarray")

    # attrs to pass to output
    ATTRS = {
        "shape_label": masks.isel(mask_layer=0).dims,
        "shape": masks.isel(mask_layer=0).shape,
    }

    # remove as it cause serialization issues
    Xd.attrs.pop("_FillValue", None)

    logger.info("Compressing and writing to zarr")

    compressor = Blosc(cname="zl4", clevel=3, shuffle=Blosc.BITSHUFFLE)

    file_output = f"{zarr_output_path}/{OUTPUT_NAME}.zarr"

    logger.info(f"Writing to {file_output}")
    logger.info(f"Progress: 0%")

    write_to_zarr(
        Xd,
        url=file_output,
        group="xd",
        storage_options={"compressor": compressor},
        chunks="auto",
        multi_index="gridcell",
        clear_zarr_storage=True,
        append_attrs=ATTRS,
        overwrite="w",
    )

    logger.info(f"Progress: 25%")

    write_to_zarr(
        Y,
        url=file_output,
        group="y",
        storage_options={"compressor": compressor},
        chunks="auto",
        multi_index="gridcell",
        append_attrs=ATTRS,
        overwrite="a",
    )

    logger.info(f"Progress: 50%")

    write_to_zarr(
        Xs,
        url=file_output,
        group="xs",
        storage_options={"compressor": compressor},
        chunks="auto",
        multi_index="gridcell",
        append_attrs=ATTRS,
        overwrite="a",
    )

    logger.info(f"Progress: 75%")

    write_to_zarr(
        masks,
        url=file_output,
        group="mask",
        storage_options={"compressor": compressor},
        overwrite="a",
    )

    logger.info(f"Progress: 100%")


if __name__ == "__main__":
    logger.info("Starting conversion to zarr")

    # Load the Paths and check if they are files

    forcings_path = sys.argv[1]
    logger.info(f"Reading forcings from {forcings_path}")
    if os.path.isdir(forcings_path):
        logger.error(
            f"FORCINGS Error: Path is a directory {forcings_path}, should be a file"
        )

    staticmaps_path = sys.argv[2]
    logger.info(f"Reading staticmaps from {staticmaps_path}")
    if os.path.isdir(staticmaps_path):
        logger.error(
            f"STATICMAPS Error: Path is a directory {staticmaps_path}, should be a file"
        )

    wflow_output_path = sys.argv[3]
    logger.info(f"Reading wflow output from {wflow_output_path}")
    if os.path.isdir(wflow_output_path):
        logger.error(f"WFLOW_OUTPUT Error: Path is a directory {
            wflow_output_path}, should be a file")

    zarr_output_path = sys.argv[4]
    logger.info(f"Zarr output path {zarr_output_path}")
    if not os.path.isdir(zarr_output_path):
        logger.error(f"ZARR_OUTPUT Error: Path is not a directory {zarr_output_path}")

    # Open each dataset and check if the required variables are present

    try:
        dynamics = xr.open_dataset(forcings_path)
        logger.info(f"Dynamics variables: {list(dynamics.variables)}")

        if not all([var in dynamics for var in DYNAMIC]):
            logger.error(
                f"FORCINGS Error: Missing dynamic variables in {forcings_path}"
            )
            sys.exit(1)

    except Exception as e:
        logger.error(f"FORCINGS Error: Error reading dynamics {e}")
        sys.exit(1)

    try:
        statics = xr.open_dataset(staticmaps_path)
        logger.info(f"Statics variables: {list(statics.variables)}")

        if not all([var in statics for var in STATIC]):
            logger.error(
                f"STATICMAPS Error: Missing static variables in {staticmaps_path}"
            )
            sys.exit(1)

    except Exception as e:
        logger.error(f"STATICMAPS Error: Error reading statics {e}")
        sys.exit(1)

    try:
        targets = xr.open_dataset(wflow_output_path)
        logger.info(f"Targets variables: {list(targets.variables)}")

        if not all([var in targets for var in TARGET]):
            logger.error(
                f"WFLOW_OUTPUT Error: Missing target variables in {wflow_output_path}"
            )
            sys.exit(1)

    except Exception as e:
        logger.error(f"WFLOW_OUTPUT Error: Error reading targets {e}")
        sys.exit(1)

    main(dynamics, statics, targets, zarr_output_path)

    logger.info(
        "Conversion to zarr completed, Congratulations, you survived to see another day!"
    )
