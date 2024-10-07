cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.0.1
s:dateCreated: '2024-08-08'
s:keywords: Hydrology, EO, CWL, AP, InterTwin, Magic
s:codeRepository: https://github.com/jzvolensky/Itwin-tech-meeting
s:releaseNotes: https://github.com/jzvolensky/Itwin-tech-meeting/blob/main/README.md
s:license: https://github.com/jzvolensky/Itwin-tech-meeting/blob/main/LICENSE
s:author:
  - s:name: Iacopo Federico Ferrario
    s:email: iacopofederico.ferrario@eurac.edu
    s:affiliation: Hydrology Magician
  - s:name: Juraj Zvolensky
    s:email: juraj.zvolensky@eurac.edu
    s:affiliation: CWL Enthusiast
$graph:
- class: Workflow
  id: hydromt-workflow
  label: Main HydroMT workflow
  doc: Run the main HydroMT workflow
  requirements:
    - class: StepInputExpressionRequirement
  inputs:
    - id: res
      type: float
    - id: precip_fn
      type: string
    - id: region
      type: string
    - id: setupconfig
      type: File
    - id: catalog
      type: File
    - id: config_gen
      type: File
  outputs:
    - id: model
      type: Directory
      outputSource: build-hydromt/model
    - id: stac_catalog
      type: Directory
      outputSource: create-stac-catalog/catalog
  steps:
    # node_update_config:
    #   run: "#update-config"
    #   in:
    #     res: res
    #     precip_fn: precip_fn
    #   out: [setupconfig]

    # node_build_hydromt:
    #   run: "#build-hydromt"
    #   in:
    #     region: region
    #     setupconfig: node_update_config/output
    #     catalog: catalog
    #   out: [model]
    # node_to_stac:
    #     run: "#create-stac-catalog"
    #     in:
    #         model: node_build_hydromt/output
    #     out: [stac_catalog]
    - id: update-config
      in:
        - id: res
          source: res
        - id: precip_fn
          source: precip_fn
      out: [setupconfig]
      run: '#update-config'
    - id: build-hydromt
      in:
        - id: region
          source: region
        - id: setupconfig
          source: update-config/setupconfig
        - id: catalog
          source: catalog
      out: [model]
      run: '#build-hydromt'
    - id: create-stac-catalog
      in:
        - id: model
          source: build-hydromt/model
      out: [catalog]
      run: '#create-stac-catalog'
- class: CommandLineTool
  id: update-config
  label: cmdtool to update the HydroMT config
  doc: Update the HydroMT config file
  baseCommand: update
  inputs:
    - id: res
      type: float
      inputBinding:
        position: 1
    - id: precip_fn
      type: string
      inputBinding:
        position: 2
  outputs:
    - id: setupconfig
      type: File
      outputBinding:
        glob: "wflow.ini"
  requirements:
    DockerRequirement:
      dockerPull: potato55/hydromt-test:0.2
      dockerOutputDirectory: /hydromt
    ResourceRequirement:
        coresMax: 2
        ramMax: 2048
    NetworkAccess:
      class: NetworkAccess
      networkAccess: true
- class: CommandLineTool
  id: build-hydromt
  baseCommand: build
  inputs:
    - id: region
      type: string
      inputBinding:
        position: 1
    - id: setupconfig
      type: File
      inputBinding:
        position: 2
    - id: catalog
      type: File
      inputBinding:
        position: 3
  outputs:
    - id: model
      type: Directory
      outputBinding:
        glob: .
  requirements:
    DockerRequirement:
      dockerPull: potato55/hydromt-test:0.2
      dockerOutputDirectory: /hydromt
    ResourceRequirement:
        coresMax: 2
        ramMax: 2048
    NetworkAccess:
      class: NetworkAccess
      networkAccess: true
- class: CommandLineTool
  id: create-stac-catalog
  label: cmdtool to create a STAC catalog
  doc: Create a STAC catalog
  baseCommand: ["python3", "/usr/bin/stac.py"]
  inputs:
    - id: model
      type: Directory
      inputBinding:
        position: 1
    - id: output_dir
      default: "./catalog"
      type: string
      inputBinding:
        position: 2
  outputs:
    - id: catalog
      type: Directory
      outputBinding:
        glob: "$(inputs.output_dir)"
  requirements:
    DockerRequirement:
      dockerPull: potato55/hydromt-test:0.2
      dockerOutputDirectory: /hydromt
    ResourceRequirement:
        coresMax: 2
        ramMax: 2048
    NetworkAccess:
      class: NetworkAccess
      networkAccess: true