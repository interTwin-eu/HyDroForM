#!/usr/bin/env bash

docker build -t hydromt-test ./workflows/hydromt/

docker container run \
    -it hydromt-test hydromt build wflow model \
    -r "{'subbasin': [11.4750, 46.8720]}" \
    -d https://raw.githubusercontent.com/jzvolensky/Itwin-tech-meeting/main/example/hydromt/cwl/tempcatalog.yaml \
    -i wflow.ini -vvv