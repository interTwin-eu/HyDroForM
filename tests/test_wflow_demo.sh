#!/usr/bin/env bash

WFLOW_DIR=$PWD/workflows/wflow

docker build -f $WFLOW_DIR/DemoDockerfile -t wflow-demo $WFLOW_DIR

docker tag wflow-demo potato55/wflow-demo:latest && docker push potato55/wflow-demo:latest
