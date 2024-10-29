#!/bin/bash

staticmaps_out=$1
forcings_out=$2


echo "Running to_stac.sh"

echo "staticmaps_out: $staticmaps_out"
echo "forcings_out: $forcings_out"

python3 /usr/bin/stac.py "$staticmaps_out" "$forcings_out"

echo "Finished running hydromt build wflow model"