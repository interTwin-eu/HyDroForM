#!/bin/bash

echo "Generating config file for HydroMT"
model_resolution=0.008999999999
dataset="cerra_land_stac"
python /usr/bin/config_gen.py "$model_resolution" "$dataset"
echo "Finished generating config file for HydroMT (wflow.ini)"

echo "Running hydromt build wflow model"
region="{'subbasin': [11.4750, 46.8720]}"
setupconfig="wflow.ini"
catalog="data_catalog.yaml"
echo "region: $region"
echo "setupconfig: $setupconfig"
echo "catalog: $catalog"
hydromt build wflow model \
-r "$region" \
-d "$catalog" \
-i "$setupconfig" -vvv
echo "Finished running hydromt build wflow model"

echo "Wrapping output files"
python /usr/bin/stac.py --staticmaps_path "./model/staticmaps.nc" --forcings_path "./model/forcings.nc" --output_dir "./model/stac"
echo "Finished wrapping output files"

# tar.gz output files (located /model/stac) and upload to MinIO
tar -czvf output.tar.gz model/stac
mv output.tar.gz $TMP_OUTPUT_DIR/output.tar.gz

echo "End of script"
