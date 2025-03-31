#!/usr/bin/env bash

container_id=$(docker run -d hydromt-app:latest /bin/bash -c "while true; do sleep 30; done;")

echo "Generating config file for HydroMT"
model_resolution=0.008999999999
dataset="cerra_land_stac"
docker exec -it $container_id python /hydromt/config_gen.py "$model_resolution" "$dataset"
echo "Finished generating config file for HydroMT (wflow.ini)"

echo "Running hydromt build wflow model"
region="{'subbasin': [11.4750, 46.8720]}"
setupconfig="/hydromt/wflow.ini"
catalog="/hydromt/data_catalog.yaml"
echo "region: $region"
echo "setupconfig: $setupconfig"
echo "catalog: $catalog"
docker exec -it $container_id hydromt build wflow model \
-r "$region" \
-d "$catalog" \
-i "$setupconfig" -vvv
echo "Finished running hydromt build wflow model"

echo "running lowercase"
docker exec -it $container_id python /hydromt/convert_lowercase.py "/hydromt/model/wflow_sbm.toml"

echo "Wrapping output files"
docker exec -it $container_id python /hydromt/stac.py --staticmaps_path "/hydromt/model/staticmaps.nc" --forcings_path "/hydromt/model/forcings.nc" --output_dir "/hydromt/model/stac"
echo "Finished wrapping output files"

docker cp $container_id:/hydromt ./output/hydromt
echo "Copied /hydromt directory to ./output/hydromt"

echo "Attaching to the running container. Type 'exit' to leave the container."
docker exec -it $container_id /bin/bash

docker stop $container_id
docker rm $container_id

echo "End of script"