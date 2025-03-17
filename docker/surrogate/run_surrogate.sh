#!/usr/bin/env bash

echo "Script to run surrogate"
echo "PWD: $PWD"

config = $1
echo "Config: $config"

pipe_key = $2
echo "Pipeline Key: $pipe_key"

itwinai exec-pipeline --config "$config" --pipe-key "$pipe_key"