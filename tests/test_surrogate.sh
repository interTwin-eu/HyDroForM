#!/usr/bin/env bash

echo $PWD


CMD="itwinai exec-pipeline --config config.yaml --pipe-key training_pipeline"

SURR_DIR=$PWD/workflows/surrogate

if [ ! -d "$SURR_DIR/tmp" ]; then
  mkdir -p $SURR_DIR/tmp 
fi

docker build --no-cache -f $SURR_DIR/TestDockerfile -t surrogate-test $SURR_DIR

if [ -z "$1" ]; then
	# CPU
	docker run -it --rm \
	    --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
	    surrogate-test /bin/bash -c "cd ./use-case && $CMD"
elif [ "$1" == "gpu" ]; then
	docker run -it --rm \
		--gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
		surrogate-test /bin/bash -c "cd ./use-case && $CMD"
fi
