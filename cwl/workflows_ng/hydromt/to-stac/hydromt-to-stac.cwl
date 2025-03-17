cwlVersion: v1.2

class: CommandLineTool
id: hydromt-to-stac

requirements:
  DockerRequirement:
    dockerPull: potato55/hydromtng:0.1
  ResourceRequirement:
    coresMax: 1
    ramMax: 2048
  NetworkAccess:
    class: NetworkAccess
    networkAccess: true

inputs:
  staticmaps_out:
    type: File
    inputBinding:
      position: 1
  forcings_out:
    type: File
    inputBinding:
      position: 2

outputs:
  json_collection:
    type: File
    outputBinding:
      glob: "WFLOW_FORCINGS_STATICMAPS/*.json"
  json_items:
    type: File[]
    outputBinding:
      glob: "WFLOW_FORCINGS_STATICMAPS/items/*.json"

baseCommand:
- bash
- /hydromt/to-stac/to_stac.sh
