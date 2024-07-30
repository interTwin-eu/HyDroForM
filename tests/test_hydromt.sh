#!/usr/bin/env bash

echo $PWD

HYDROMT_DIR=$PWD/workflows/hydromt

docker build --no-cache -t hydromt-test $HYDROMT_DIR

docker container run -v /mnt/CEPH_PROJECTS/InterTwin/hydrologic_data:/data \
    -it hydromt-test hydromt build wflow model \
    -r "{'subbasin': [11.4750, 46.8720]}" \
    -d data_catalog.yaml -i wflow.ini -vvv
