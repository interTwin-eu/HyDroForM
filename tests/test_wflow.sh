#!/usr/bin/env bash

WFLOW_DIR=$PWD/docker/wflow

docker build -f $WFLOW_DIR/Dockerfile -t wflow-test $WFLOW_DIR

# Run the wflow container
# 1. Read STAC, which accepts a single collection or a list of collections + output path
# It also supports downloading the wflow_sbm.toml
# 2. Run wflow model
# 3. Convert the output to zarr format
# python to_zarr.py /path/to/dynamics.nc /path/to/statics.nc /path/to/targets.nc /path/to/output.zarr
# 4. TODO: Zarr to STAC

docker container run \
    -v $PWD/tests/tmp/:/data \
    -it --rm wflow-test /bin/bash -c \
    "python3 /app/src/read_stac.py "https://stac.eurac.edu/collections/MERIT_HYDRO" "data" \
    && run_wflow /data/wflow_sbm.toml" # \
    && python3 /app/src/to_zarr.py ADD HERE "

