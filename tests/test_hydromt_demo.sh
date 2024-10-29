#!/usr/bin/env bash

echo $PWD

HYDROMT_DIR=$PWD/workflows/hydromt

if [ ! -d "$HYDROMT_DIR/tmp" ]; then
  mkdir -p $HYDROMT_DIR/tmp 
fi

docker build --no-cache -f $HYDROMT_DIR/DemoDockerfile -t hydromt-demo $HYDROMT_DIR

docker tag hydromt-demo potato55/hydromt-demo:stac # && docker push potato55/hydromt-demo:stac


