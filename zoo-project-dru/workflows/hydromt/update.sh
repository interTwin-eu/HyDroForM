#!/usr/bin/env bash

res=$1
precip_fn=$2

# Run update config to update the config file with the new values

echo "res: $res"
echo "precip_fn: $precip_fn"

echo "Running config_gen.py"

cd /hydromt

python3 /usr/bin/config_gen.py "$res" "$precip_fn"

echo "Finished running config_gen.py"
echo "New config values: $res, $precip_fn"