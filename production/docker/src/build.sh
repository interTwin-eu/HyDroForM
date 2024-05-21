#!/bin/bash

## processing arguments
region=$1
setupconfig=$2
catalog=$3

# Run update config to update the config file with the new values

cd /hydromt

## run application

echo "Running hydromt build wflow model"

hydromt build wflow model \
-r "$region" \
-d "$catalog" \
-i "$setupconfig" -vvv 

echo "Finished running hydromt build wflow model"

