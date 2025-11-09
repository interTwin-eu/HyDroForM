#!/usr/bin/env bash

echo "OSCAR Surrogate Script Started"

echo "Reading environment variables for surrogate training"

echo $PWD

# Read environment variables
mlflow_tracking_uri="${MLFLOW_TRACKING_URI}"
mlflow_tracking_username="${MLFLOW_TRACKING_USERNAME}"
mlflow_tracking_insecure_tls="${MLFLOW_TRACKING_INSECURE_TLS}"
mlflow_tracking_password="${MLFLOW_TRACKING_PASSWORD}"
aws_access_key="${AWS_ACCESS_KEY_ID}"
aws_secret_key="${AWS_SECRET_ACCESS_KEY}"

SURR_DIR=$PWD/docker/surrogate

if [ ! -d "$SURR_DIR/tmp" ]; then
  mkdir -p $SURR_DIR/tmp
fi

if [ -z "$1" ]; then
	# CPU
	docker run -it --rm \
	-v "$PWD/tests/tmp:/data" \
	--ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
	-e MLFLOW_TRACKING_URI=$mlflow_tracking_uri \
	-e MLFLOW_TRACKING_USERNAME=$mlflow_tracking_username \
	-e MLFLOW_TRACKING_INSECURE_TLS=$mlflow_tracking_insecure_tls \
	-e MLFLOW_TRACKING_PASSWORD=$mlflow_tracking_password \
	-e AWS_ACCESS_KEY_ID=$aws_access_key \
	-e AWS_SECRET_ACCESS_KEY=$aws_secret_key \
	surrogate-test:latest /bin/bash -c "python ./use-case/gen_surr_config.py \
		--config './use-case/training_local.yaml' \
		--output './use-case/training_local_updated.yaml' \
		--cp 'train_temporal_range=[\"2001-01-01\", \"2001-03-31\"]' \
		--cp 'valid_temporal_range=[\"2001-01-01\", \"2001-03-31\"]' \
		--cp 'test_temporal_range=[\"2001-01-01\", \"2001-03-31\"]' \
		&& cat ./use-case/training_local_updated.yaml \
		&& itwinai exec-pipeline --config-dir ./use-case --config-name training_local_updated"


elif [ "$1" == "gpu" ]; then
	echo "Running with GPU"
	docker run -it --rm \
		-v $PWD/tests/tmp:/model \
		-v /mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/surrogate_input:/data \
		--gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
		-e MLFLOW_TRACKING_URI=$mlflow_tracking_uri -e MLFLOW_TRACKING_USERNAME=$mlflow_tracking_username \
		-e MLFLOW_TRACKING_INSECURE_TLS=$mlflow_tracking_insecure_tls -e MLFLOW_TRACKING_PASSWORD=$mlflow_tracking_password \
		-e AWS_ACCESS_KEY_ID=$aws_access_key -e AWS_SECRET_ACCESS_KEY=$aws_secret_key \
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