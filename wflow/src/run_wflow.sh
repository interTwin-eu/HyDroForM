#!/bin/bash

## read STAC catalogue

## get assets (forcings.nc, staticmaps.nc, ..)

## processing arguments

runconfig=$1
 
## run application

wflow "$runconfig" # default to 4 threads 

## add result to catalog

