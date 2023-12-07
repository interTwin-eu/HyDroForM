#!/bin/bash

## processing arguments
setupconfig=$1
catalog=$2
region=$3

## get item/asset

## run application

hydromt build wflow \
-o /model \
-r "$region" \
-d "$catalog" \
-i "$setupconfig" 

## add result to catalog
