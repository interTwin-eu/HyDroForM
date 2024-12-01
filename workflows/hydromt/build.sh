#!/bin/bash

## processing arguments
region=$1
setupconfig=$2
catalog=$3

echo "Running hydromt build wflow model"

echo "region: $region"
echo "setupconfig: $setupconfig"
echo "catalog: $catalog"

hydromt build wflow model \
-r "$region" \
-d "$catalog" \
-i "$setupconfig" -vvv 

echo "Finished running hydromt build wflow model"

# echo "Running to_stac.sh"

# echo $PWD

# cd /hydromt

# staticmaps_out="./model/staticmaps.nc"
# forcings_out="./model/forcings.nc"

# chmod 644 "$staticmaps_out"
# chmod 644 "$forcings_out"

# echo "staticmaps_out: $staticmaps_out"
# echo "forcings_out: $forcings_out"

# python3 /usr/bin/stac.py --staticmaps_path "$staticmaps_out" --forcings_path "$forcings_out"

# echo "FINISHED TO STAC"