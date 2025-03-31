cwlVersion: v1.2
class: Workflow
id: hydromt-workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  res: float
  precip_fn: string
  region: string
  #catalog: File
  aws_access_key: string
  aws_secret_key: string

outputs:
  setupconfig:
    type: File
    outputSource: update-config/wflow_ini        #update-config/setupconfig
  catalog:
    type: File
    outputSource: generate-catalog/data_catalog
  model:
    type: Directory
    outputSource: build-hydromt/model
  staticmaps_out:
    type: File
    outputSource: build-hydromt/staticmaps_out
  forcings_out:
    type: File
    outputSource: build-hydromt/forcings_out
  stac_collection:
    type: File
    outputSource: to-stac/stac_collection
  stac_items:
    type: File[]
    outputSource: to-stac/stac_items

steps:
  update-config:
    run: ./config-update/hydromt-config-update-sh.cwl
    in:
      res: res
      precip_fn: precip_fn
    out:
      - wflow_ini
  generate-catalog:
    run: ./catalog-update/hydromt-catalog-update-sh.cwl
    in: {}
    out:
      - data_catalog

  build-hydromt:
    run: ./hydromt-build/hydromt-build-sh.cwl
    in:
      region: region
      setupconfig: update-config/wflow_ini
      catalog: generate-catalog/data_catalog
    out:
      - model
      - staticmaps_out
      - forcings_out

  to-stac:
    run: ./to-stac/hydromt-to-stac-sh.cwl
    in:
      staticmaps_path: build-hydromt/staticmaps_out
      forcings_path: build-hydromt/forcings_out
      aws_access_key: aws_access_key
      aws_secret_key: aws_secret_key
    out:
      - stac_collection
      - stac_items
