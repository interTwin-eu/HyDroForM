#!/bin/bash

## read STAC catalogue

## get assets (forcings.nc, staticmaps.nc, ..)

## processing arguments

runner=$1
runconfig=$2
 
## run application

julia --project=/env -t 4 "$runner" --runconfig "$runconfig" # default to 4 threads 

## add result to catalog

