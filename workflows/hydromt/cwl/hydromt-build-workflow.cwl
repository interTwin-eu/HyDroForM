cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.0.1
s:dateCreated: '2024-06-05'
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
  - class: CommandLineTool
    id: update-config
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
        dockerPull: potato55/hydromt:vienna
        dockerOutputDirectory: /hydromt
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
      - id: volume_data
        type: Directory
        inputBinding:
          position: 4
    outputs:
      - id: model
        type: Directory
        outputBinding:
          glob: .
    requirements:
      DockerRequirement:
        dockerPull: potato55/hydromt:vienna
        dockerOutputDirectory: /hydromt
      InitialWorkDirRequirement:
        listing:
          - entryname: /data
            entry: $(inputs.volume_data)
      NetworkAccess:
        class: NetworkAccess
        networkAccess: true
  - class: CommandLineTool
    id: create-stac-catalog
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
        dockerPull: potato55/hydromt:vienna
        dockerOutputDirectory: /hydromt
  - class: Workflow
    id: hydromt-workflow
    requirements:
      - class: StepInputExpressionRequirement
    inputs:
      - id: res
        type: float
      - id: precip_fn
        type: string
      - id: region
        type: string
      - id: catalog
        type: File
      - id: volume_data
        type: Directory
    outputs:
      - id: model
        type: Directory
        outputSource: build-hydromt/model
      - id: stac_catalog
        type: Directory
        outputSource: create-stac-catalog/catalog
    steps:
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
          - id: volume_data
            source: volume_data
        out: [model]
        run: '#build-hydromt'
      - id: create-stac-catalog
        in:
          - id: model
            source: build-hydromt/model
        out: [catalog]
        run: '#create-stac-catalog'