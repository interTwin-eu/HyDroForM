#!/usr/bin/env bash

res=$1
precip_fn=$2

# Debugging: Print the current working directory
echo "Current working directory: $(pwd)"

# Debugging: List all files and directories in the current working directory
echo "Listing all files and directories in the current working directory:"
ls -al

# Debugging: List all files and directories in the /hydromt directory
echo "Listing all files and directories in the /hydromt directory:"
ls -al /hydromt

# Run update config to update the config file with the new values
echo "res: $res"
echo "precip_fn: $precip_fn"

echo "Running config_gen.py"

#cd /hydromt

python3 /hydromt/config-update/config_gen.py "$res" "$precip_fn"

echo "Finished running config_gen.py"
echo "New config values: $res, $precip_fn"

ls -al