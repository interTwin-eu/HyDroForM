cwlVersion: v1.2

class: CommandLineTool
baseCommand: [run_wflow.sh]
label: hydromt_wflow
inputs:
  data:
    type: Directory
    inputBinding:
      position: 1
outputs: []
