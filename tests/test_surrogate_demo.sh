#!/usr/bin/env bash

SURR_DIR=$PWD/workflows/surrogate

docker build --no-cache -f $SURR_DIR/TestDockerfile -t surrogate-test $SURR_DIR

docker tag surrogate-test potato55/surrogate-test:latest && docker push potato55/surrogate-test:latest