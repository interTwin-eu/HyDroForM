#!/usr/bin/env bash

WFLOW_DIR=$PWD/docker/wflow

docker build -f $WFLOW_DIR/Dockerfile -t wflow-test $WFLOW_DIR


docker container run \
    -v $PWD/tests/tmp/:/data \
    -it --rm wflow-test \
    run_wflow /data/wflow_sbm.toml 

