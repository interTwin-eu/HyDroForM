#!/bin/bash

if [ "$#" -lt 2 ]
then
  echo "Usage: provide forcings, output"
  exit 1
fi

## read STAC catalogue

## processing arguments
forcing=$1
output=$2

## get item/asset

## run application

julia  --project=/env \
    -t 4 /src/run.jl \
    --forcing ${forcing} \
    --output ${output}

## add result to catalog
