#!/usr/bin/env bash
if [ $# -eq 0 ]
  then
    tag='hydromt'
  else
    tag=$1
fi

docker build -t intertwin:$tag .
