#!/usr/bin/env bash

echo $PWD

HYDROMT_DIR=$PWD/workflows/hydromt

if [ ! -d "$HYDROMT_DIR/tmp" ]; then
  mkdir -p $HYDROMT_DIR/tmp 
fi

docker build --no-cache -f $HYDROMT_DIR/TestDockerfile -t hydromt-test $HYDROMT_DIR

docker container run \
    -v $PWD/tests/tmp:/hydromt/model \
    -it --rm hydromt-test hydromt build wflow model \
    -r "{'subbasin': [11.4750, 46.8720]}" \
    -d data_catalog.yaml -i wflow.ini -vvv


