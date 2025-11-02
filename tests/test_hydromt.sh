#!/usr/bin/env bash

echo $PWD

HYDROMT_DIR=$PWD/docker/hydromt

# Source credentials for AWS S3 bucket
source $PWD/tests/.env_s3_intertwin
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

model_resolution="${MODEL_RESOLUTION:-0.008999999999}"
precip_fn="${PRECIP_FN:-emo1_stac}"
starttime="${STARTTIME:-2001-01-01T00:00:00}"
endtime="${ENDTIME:-2001-03-31T00:00:00}"

docker container run \
    -v $PWD/tests/tmp:/hydromt/model \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY \
    -it --rm potato55/hydromt-test:r2sfix /bin/bash -c "
    python config_gen.py \
        --res \"$model_resolution\" \
        --precip_fn \"$precip_fn\" \
        --starttime \"$starttime\" \
        --endtime \"$endtime\" \
    && hydromt build wflow model -r \"{'subbasin': [11.4750, 46.8720]}\" -d data_catalog.yaml -i wflow.ini -vvv \
    && python /hydromt/convert_lowercase.py \"/hydromt/model/wflow_sbm.toml\" \
    && python /hydromt/stac.py --staticmaps_path \"/hydromt/model/staticmaps.nc\" --forcings_path \"/hydromt/model/forcings.nc\" --wflow_sbm_path \"/hydromt/model/wflow_sbm.toml\" --output_dir \"/hydromt/model/stac\"
    "



    # python config_gen.py \
    #     --res "0.008999999999" \
    #     --precip_fn "emo1_stac" \
    #     --starttime "2001-01-01T00:00:00" \
    #     --endtime "2001-03-31T00:00:00" \
