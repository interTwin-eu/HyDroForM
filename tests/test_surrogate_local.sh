#!/usr/bin/env bash

echo $PWD

SURR_DIR=$PWD/docker/surrogate

if [ ! -d "$SURR_DIR/tmp" ]; then
  mkdir -p $SURR_DIR/tmp 
fi

docker build --no-cache -f $SURR_DIR/Dockerfile -t surrogate-test $SURR_DIR

if [ -z "$1" ]; then
	# CPU
	docker run -it --rm \
		-v $PWD/tests/tmp:/app/use-case \
		-v /mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/surrogate_input:/data \
	    --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
	    surrogate-test:latest /bin/bash -c 'itwinai exec-pipeline --config-path /app/use-case --config-name training_local'
elif [ "$1" == "gpu" ]; then
	echo "Running with GPU"
	docker run -it --rm \
		-v $PWD/tests/tmp:/app/use-case \
		-v /mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/surrogate_input:/data \
		--gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
		surrogate-test:latest /bin/bash -c 'itwinai exec-pipeline --config-path /app/use-case --config-name training_local'
fi


#docker run -it surrogate-test /bin/bash -c "cd ./use-case && itwinai exec-pipeline --config-name config"