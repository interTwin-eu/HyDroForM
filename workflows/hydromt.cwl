#!/usr/bin/env cwl-runner

cwlVersion: v1.2
$graph:
- class: Workflow
  label: HydroMT 
  doc: building, updating WFLOW
  id: hydromt

  inputs:
    setupconfig:
      type: File
      label: Sentinel-2 inputs
      doc: Sentinel-2 Level-1C or Level-2A input reference
      default: wflow.ini
    catalog:
      type: File
      label: Sentinel-2 band
      doc: Sentinel-2 band to crop (e.g. B02)
      default: hydromt_data.yaml
    region:
      type: string
      label: region
      doc: Area of interest expressed as a bounding bbox
      default: "{'subbasin':'./points.geojson', 'strord':3}"

  outputs:
    results:
      outputSource:
      - node_hydromt/wflow_model
      type: Directory

  steps:

    node_hydromt:

      run: "#hydromt-build"

      in:
        setupconfig: setupconfig
        catalog: catalog
        region: region

      out:
        - wflow_model

- class: CommandLineTool

  id: hydromt-build

  requirements:
    DockerRequirement:
      dockerPull: gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:hydromt

  baseCommand: build
  arguments: []

  inputs:
    setupconfig:
      type: File
      inputBinding:
        position: 1
    catalog:
      type: File
      inputBinding:
        position: 2
    region:
      type: string
      inputBinding:
        position: 3

  outputs:
    wflow_model:
      outputBinding:
        glob: .
      type: Directory
