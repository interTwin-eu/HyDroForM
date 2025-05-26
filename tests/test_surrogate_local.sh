#!/usr/bin/env bash

echo $PWD

SURR_DIR=$PWD/docker/surrogate

if [ ! -d "$SURR_DIR/tmp" ]; then
  mkdir -p $SURR_DIR/tmp 
fi

# Source credentials for MLFLOW server
source $PWD/tests/.env_mlflow

# Source credentials for AWS S3 bucket
source $PWD/tests/.env_s3

docker build --no-cache -f $SURR_DIR/Dockerfile -t surrogate-test $SURR_DIR

if [ -z "$1" ]; then
	# CPU
	docker run -it --rm \
		-v $PWD/tests/tmp:/data \
	    --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
		-e MLFLOW_TRACKING_URI=$MLFLOW_TRACKING_URI -e MLFLOW_TRACKING_USERNAME=$MLFLOW_TRACKING_USERNAME \
		-e MLFLOW_TRACKING_INSECURE_TLS=$MLFLOW_TRACKING_INSECURE_TLS -e MLFLOW_TRACKING_PASSWORD=$MLFLOW_TRACKING_PASSWORD \
		-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY \
	    surrogate-test:latest /bin/bash -c "python ./use-case/gen_surr_config.py --config "./use-case/training_local.yaml" --output "./use-case/training_local_updated.yaml" \
		--cp 'train_temporal_range=["2015-01-01", "2016-12-01"]' \
		--cp 'valid_temporal_range=["2015-01-01", "2016-12-01"]' \
		--cp 'test_temporal_range=["2015-01-01", "2016-12-01"]' \
		&& cat ./use-case/training_local_updated.yaml \
		&& itwinai exec-pipeline --config-dir ./use-case --config-name training_local_updated "

elif [ "$1" == "gpu" ]; then
	echo "Running with GPU"
	docker run -it --rm \
		-v $PWD/tests/tmp:/model \
		-v /mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/surrogate_input:/data \
		--gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
		-e MLFLOW_TRACKING_URI=$MLFLOW_TRACKING_URI -e MLFLOW_TRACKING_USERNAME=$MLFLOW_TRACKING_USERNAME \
		-e MLFLOW_TRACKING_INSECURE_TLS=$MLFLOW_TRACKING_INSECURE_TLS -e MLFLOW_TRACKING_PASSWORD=$MLFLOW_TRACKING_PASSWORD \
		-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY \
	    surrogate-test:latest /bin/bash -c '
		    echo "Inside container:"
			echo "Working dir: $(pwd)"
			echo "Contents of /app/use-case:"
			ls -lah /app/use-case
			echo "Contents of /data:"
			ls -lah /data
			echo "Environment:"
			env
			echo "Starting pipeline..."
			itwinai exec-pipeline --config-dir ./use-case --config-name training_local
	'
fi


#docker run -it surrogate-test /bin/bash -c "cd ./use-case && itwinai exec-pipeline --config-name config"