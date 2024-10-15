"""

python wflow2hython.py "/path/to/input/dir" "/path/to/output/dir"

"""


import xarray as xr
import numpy as np
from hython.preprocessor import reshape 
from hython.io import write_to_zarr, read_from_zarr 
from hython.utils import build_mask_dataarray
from numcodecs import Blosc
import sys


DIR_INPUT = "."
DIR_OUTPUT = "."
OUTPUT_NAME = "demo"

DYNAMIC = ["precip", "pet", "temp"]
STATIC = ["thetaS", "thetaR"]
TARGET = ["vwc", "actevap"]
MASK_FROM_STATIC = ["thetaS" ]
RENAME_MASK = ["mask_missing"]



def main(dynamics, statics, targets, wd, dir_out):
    
    try:
        dynamics = dynamics.rename({"latitude":"lat", "longitude":"lon"})
        statics = statics.rename({"latitude":"lat", "longitude":"lon"})
    except:
        pass

    targets = targets.isel(lat=slice(None, None, -1)).sel(layer=1)
    statics = statics.sel(layer=1)

    masks = []
    for i, mask in enumerate(MASK_FROM_STATIC):
        if i == 0:
            masks.append(np.isnan(statics[mask]).rename(RENAME_MASK[i]))
        else:
            masks.append((statics[mask] > 0).astype(np.bool_).rename(RENAME_MASK[i]))

    masks = build_mask_dataarray(masks, names = RENAME_MASK)

    Xd = reshape(dynamics,"dynamic", return_type="xarray")
    Xs = reshape(statics.drop_dims("time"), "static", return_type="xarray")
    Y = reshape(targets, "target", return_type="xarray")

    # attrs to pass to output
    ATTRS = {
            "shape_label":masks.isel(mask_layer=0).dims,
            "shape":masks.isel(mask_layer=0).shape
            }
    
    # remove as it cause serialization issues
    Xd.attrs.pop("_FillValue", None)

    compressor = Blosc(cname='zl4', clevel=3, shuffle=Blosc.BITSHUFFLE)

    file_output = f"{dir_out}/{OUTPUT_NAME}.zarr"

    write_to_zarr(Xd,
                url= file_output, 
                group="xd", 
                storage_options={"compressor":compressor}, 
                chunks="auto", 
                multi_index="gridcell", 
                clear_zarr_storage=True,
                append_attrs = ATTRS, 
                overwrite="w")

    write_to_zarr(Y ,
                url= file_output,  
                group="y", 
                storage_options={"compressor":compressor}, 
                chunks="auto", 
                multi_index="gridcell",
                append_attrs = ATTRS,
                    overwrite="a")


    write_to_zarr(Xs ,
                url= file_output, 
                group="xs", 
                storage_options={"compressor":compressor}, 
                chunks="auto", 
                multi_index="gridcell",
                append_attrs = ATTRS,
                overwrite="a")

    write_to_zarr(masks,
                url= file_output, 
                group="mask", 
                storage_options={"compressor":compressor}, 
                overwrite="a")

if __name__ == "__main__":


    WD = sys.argv[1]
    OUT = sys.argv[2]

    if WD is None: WD = DIR_INPUT
    if OUT is None: OUT = DIR_OUTPUT

    dynamics = xr.open_dataset(f"{WD}forcings.nc")
    statics = xr.open_dataset(f"{WD}staticmaps.nc")
    targets = xr.open_dataset(f"{WD}run_default/output.nc")


    main(dynamics, statics, targets, WD, OUT)
