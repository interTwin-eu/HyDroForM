#!/bin/bash

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
