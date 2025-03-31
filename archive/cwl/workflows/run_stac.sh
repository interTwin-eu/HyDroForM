#!/usr/bin/env bash

staticmaps=$1
forcings=$2
# Run update config to update the config file with the new values

python3 /usr/bin/stac.py "$staticmaps $forcings"


echo $PWD