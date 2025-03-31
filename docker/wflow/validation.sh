#!/usr/bin/env bash 

container_id=$(docker run -v "$(pwd)/docker/hydromt/output/hydromt:/data" -d wflow-app:latest /bin/bash -c "while true; do sleep 30; done;")

echo "Started Wflow container with id: $container_id"

echo "Running wflow build"
docker exec -it $container_id run_wflow "/data/model/wflow_sbm.toml"