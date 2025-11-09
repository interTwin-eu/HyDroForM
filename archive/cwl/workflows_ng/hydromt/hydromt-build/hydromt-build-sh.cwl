cwlVersion: v1.2
class: CommandLineTool
baseCommand: ["bash", "build_hydromt.sh"]

requirements:
  DockerRequirement:
    dockerPull: potato55/hydromtng:0.1
  InitialWorkDirRequirement:
    listing:
      - entryname: build_hydromt.sh
        entry: |
          #!/usr/bin/env bash

          region=$1
          setupconfig=$2
          catalog=$3

          echo "Running hydromt build wflow model"
          cat $catalog
          echo "region: $region"
          echo "setupconfig: $setupconfig"
          echo "catalog: $catalog"

          hydromt build wflow model \
          -r "$region" \
          -d "$catalog" \
          -i "$setupconfig" -vvv

          echo "Finished running hydromt build wflow model"

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
