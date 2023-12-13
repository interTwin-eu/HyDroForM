#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: Workflow
label: HydroMT 
doc: building, updating WFLOW
id: hydromt

inputs:
    region:
        type: string

outputs:
    results:
        outputSource: region
        type: string

steps:
    hydromt-build:
        run: hydromt-build.cwl
        in:
            region:
                label: region
                default: "{'subbasin':'./points.geojson', 'strord':3}"
            setupconfig:
                label: Sentinel-2 inputs
                default: wflow.ini
            catalog:
                label: Sentinel-2 band
                default: hydromt_data.yaml

        out:
            - wflow_model
