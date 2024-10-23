#!/usr/bin/env bash

runconfig=$1
# Run update config to update the config file with the new values

echo "runconfig: $runconfig"

echo "Running convert_lowercase"
echo $PWD
cd /hydromt

python3 /usr/bin/convert_lowercase.py "$runconfig"

echo "Finished running config_gen.py"
echo "New config values: $runconfig"

echo $PWD

# Append the new section to the TOML file
cat <<EOL >> "$runconfig"

[output.vertical]
actevap = "actevap"
vwc = "vwc"
EOL

echo "Appended new section to $runconfig"