cwlVersion: v1.0
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
    catalog:
      type: File
      label: Sentinel-2 band
      doc: Sentinel-2 band to crop (e.g. B02)
    region:
      type: string
      label: region
      doc: Area of interest expressed as a bounding bbox

  outputs:
    results:
      outputSource:
      - hydromt_build/wflow_model
      type: Directory

  steps:

    hydromt_build:

      run: "#hydromt_build"

      in:
        setupconfig: setupconfig
        catalog: catalog
        region: region

      out:
        - wflow_model


- class: CommandLineTool

  id: hydromt_build

  requirements:
    DockerRequirement:
      dockerPull: docker.io/terradue/crop-container

  baseCommand: crop
  arguments: []

  inputs:
    product:
      type: Directory
      inputBinding:
        position: 1
    band:
      type: string
      inputBinding:
        position: 2
    bbox:
      type: string
      inputBinding:
        position: 3
    epsg:
      type: string
      inputBinding:
        position: 4

  outputs:
    cropped_tif:
      outputBinding:
        glob: .
      type: Directory

$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.0.0
schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf
