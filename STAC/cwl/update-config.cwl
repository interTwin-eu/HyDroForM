$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.0.1
s:dateCreated: '2024-02-21'
s:codeRepository: https://github.com/interTwin-eu/HyDroForM
s:author:
  - s:name: Iacopo Federico Ferrario
    s:email: iacopofederico.ferrario@eurac.edu
    s:affiliation: Hydrology magician
  - s:name: Juraj Zvolensky
    s:email: juraj.zvolensky@eurac.edu
    s:affiliation: CWL enthusiast
s:about:
  - s:name: Configuration update
    s:description: |
      This tool updates the configuration file for the HydroMT model.
      The parameters for the configuration file are passed as inputs.
      These are processed in a Python script and the updated configuration
      file is generated and returned as output to build the model.

cwlVersion: v1.2
class: CommandLineTool
id: hydromt-config-update
baseCommand:
  - python3
  - config_gen.py
doc: Update the HydroMT configuration file
inputs:
  - id: res
    label: Resolution of the model
    type: float
    inputBinding:
      position: 1
  - id: precip_fn
    label: Select which precipitation forcing to use
    type: string
    inputBinding:
      position: 2
  - id: config_generator
    label: Update config script
    type: File
  - id: setupconfig
    label: original wflow.ini from params
    type: File
outputs:
  - id: updated_config
    type: File
    outputBinding:
      glob: wflow.ini
requirements:
  DockerRequirement:
    dockerPull: potato55/hydromt:test
    dockerOutputDirectory: /hydromt
  InitialWorkDirRequirement: 
    listing:  
      - entryname: workdir 
        entry: /hydromt
        writable: true
      - entry: $(inputs.config_generator)
        writable: true
      - entry: $(inputs.setupconfig)
        writable: true
  NetworkAccess:
    class: NetworkAccess
    networkAccess: true