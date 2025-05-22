#!/usr/bin/env bash

echo $PWD

WFLOW_DIR=$PWD/docker/wflow

source $PWD/tests/.env_s3_intertwin
echo $AWS_ACCESS_KEY
echo $AWS_SECRET_KEY

docker build --no-cache -f $WFLOW_DIR/Dockerfile -t wflow-test $WFLOW_DIR

# Run the wflow container
# 1. Read STAC, which accepts a single collection or a list of collections + output path
# It also supports downloading the wflow_sbm.toml
# 2. Run wflow model
# 3. Convert the output to zarr format
# python to_zarr.py /path/to/dynamics.nc /path/to/statics.nc /path/to/targets.nc /path/to/output.zarr
# 4. TODO: Zarr to STAC

docker container run \
    -v $PWD/tests/tmp/:/data \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY \
    -it --rm wflow-test /bin/bash -c \
    'python3 /app/src/read_stac.py "https://stac.intertwin.fedcloud.eu/collections/8db57c23-4013-45d3-a2f5-a73abf64adc4_WFLOW_FORCINGS_STATICMAPS" "data" \
    && run_wflow "/data/wflow_sbm.toml" \
    && python3 /app/src/to_zarr.py "/data/forcings.nc" "/data/staticmaps.nc" "/data/run_default/output.nc" "/data"'
