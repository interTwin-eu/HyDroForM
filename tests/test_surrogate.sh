#!/usr/bin/env bash

echo $PWD

SURR_DIR=$PWD/workflows/surrogate

if [ ! -d "$SURR_DIR/tmp" ]; then
  mkdir -p $SURR_DIR/tmp 
fi

docker build --no-cache -f $SURR_DIR/TestDockerfile -t surrogate-test $SURR_DIR

docker container run -it --rm surrogate-test itwinai exec-pipeline --config ./use-case/config.yaml --pipe-key training_pipeline

