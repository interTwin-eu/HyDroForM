#!/bin/bash

## processing arguments
region=$1
setupconfig=$2
catalog=$3

## run application

hydromt build wflow model \
-r "$region" \
-d "$catalog" \
-i "$setupconfig" -vvv 

## add results to STAC catalog

