cwlVersion: v1.2
class: CommandLineTool
id: build-hydromt

requirements:
  DockerRequirement:
    dockerPull: potato55/hydromtng:0.1
  NetworkAccess:
    class: NetworkAccess
    networkAccess: true
  ResourceRequirement:
    coresMin: 1
    coresMax: 2
    ramMin: 512
    ramMax: 2048

inputs:
  region:
    type: string
    inputBinding:
      position: 1
  setupconfig:
    type: File
    inputBinding:
      position: 2
  catalog:
    type: File
    inputBinding:
      position: 3

outputs:
  model:
    type: Directory
    outputBinding:
      glob: .
  staticmaps_out:
    type: File
    outputBinding:
      glob: "model/staticmaps.nc"
  forcings_out:
    type: File
    outputBinding:
      glob: "model/forcings.nc"

baseCommand:
- bash
- /hydromt/hydromt-build/build.sh
