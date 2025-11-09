#!/usr/bin/env bash

LOCAL_OUTPUT_DIR=""

#docker build -f Dockerfile -t wflow-test .

docker container run \
    -v "$(pwd)/docker/hydromt/output/hydromt:/data" \
    -it --rm wflow-test \
    run_wflow "/data/model/wflow_sbm.toml"
