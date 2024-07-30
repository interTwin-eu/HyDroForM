#!/usr/bin/env bash

echo $PWD

HYDROMT_DIR=$PWD/workflows/hydromt

docker build --no-cache -f $HYDROMT_DIR/TestDockerfile -t hydromt-test $HYDROMT_DIR

docker container run \
    -it hydromt-test hydromt build wflow model \
    -r "{'subbasin': [11.4750, 46.8720]}" \
    -d data_catalog.yaml -i wflow.ini -vvv
