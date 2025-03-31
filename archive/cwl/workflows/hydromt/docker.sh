#!/usr/bin/env bash
if [ $# -eq 0 ]
  then
    tag='hydromt'
  else
    tag=$1
fi


docker build -t gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:hydromt .

docker push gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:hydromt