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

#hydromt build wflow model -r "{'subbasin': [11.4750, 46.8720]}" -d "https://raw.githubusercontent.com/jzvolensky/Itwin-tech-meeting/main/example/hydromt/cwl/tempcatalog.yaml" -i "https://raw.githubusercontent.com/jzvolensky/Itwin-tech-meeting/main/example/hydromt/wflow.ini" -vvv