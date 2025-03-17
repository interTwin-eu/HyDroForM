#!/bin/bash

region="{'subbasin': [11.4750, 46.8720]}"
setupconfig="wflow.ini"
catalog="data_catalog.yaml"

echo "Running hydromt build wflow model"

echo "region: $region"
echo "setupconfig: $setupconfig"
echo "catalog: $catalog"

hydromt build wflow model \
-r "$region" \
-d "$catalog" \
-i "$setupconfig" -vvv 

echo "Finished running hydromt build wflow model"
