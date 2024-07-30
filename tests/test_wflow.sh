#!/usr/bin/env bash

docker build -t wflow-test ./workflows/wflow/

cd tests/hydromt/model

docker container run \
    -it wflow-test