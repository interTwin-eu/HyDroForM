#!/usr/bin/env bash

echo $PWD

HYDROMT_DIR=$PWD/docker/hydromt

# Source credentials for AWS S3 bucket
source $PWD/tests/.env_s3
echo $AWS_ACCESS_KEY
echo $AWS_SECRET_KEY

if [ ! -d "$HYDROMT_DIR/tmp" ]; then
  mkdir -p $HYDROMT_DIR/tmp 
fi

docker build --no-cache -f $HYDROMT_DIR/Dockerfile -t hydromt-test $HYDROMT_DIR

# Run the container
# 1. config generation
# 2. build wflow model
# 3. convert variables to lowercase (total BS but needed)
# 4. generate STAC metadata

docker container run \
    -v $PWD/tests/tmp:/hydromt/model \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY \
    -it --rm hydromt-test /bin/bash -c "python config_gen.py "0.008999999999" "emo1_stac" \
    && hydromt build wflow model -r \"{'subbasin': [ 11.293337, 45.014857 ], 'strord': 3}\" -d data_catalog.yaml -i wflow.ini -vvv \
    && python /hydromt/convert_lowercase.py "/hydromt/model/wflow_sbm.toml" \
    && python /hydromt/stac.py --staticmaps_path "/hydromt/model/staticmaps.nc" --forcings_path "/hydromt/model/forcings.nc" --output_dir "/hydromt/model/stac" "


