#!/bin/bash

## processing arguments
region=$1
setupconfig=$2
catalog=$3

res=$4
precip_fn=$5

# Run update config to update the config file with the new values

echo "Running update_config.py"

cd /hydromt

python3 /usr/bin/update_config.py "$res" "$precip_fn"

echo "Finished running update_config.py"
## run application

echo "Running hydromt build wflow model"

hydromt build wflow model \
-r "$region" \
-d "$catalog" \
-i "$setupconfig" -vvv 

echo "Finished running hydromt build wflow model"

