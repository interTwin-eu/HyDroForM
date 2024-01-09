#!/bin/bash

## read STAC catalogue

## processing arguments

runconfig=$1
#output=$2

## get item/asset

## run application

julia --project=/env -t 4 wflow --runconfig ./data/${runconfig}

#julia --project=/env -t 4 -e 'using Wflow; Wflow.run(ENV["runconfig"])'

#    --forcing ${forcing} \
#    --output ${output}

## add result to catalog
