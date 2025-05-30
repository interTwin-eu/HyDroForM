cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.9.9
s:dateCreated: '2024-10-17'
s:keywords: Hydrology, EO, CWL, AP, InterTwin, Magic
s:codeRepository: https://github.com/jzvolensky/Itwin-tech-meeting
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
        dockerPull: potato55/hydromt-demo:stac  #potato55/hydromt-test:buildfix
        dockerOutputDirectory: /hydromt
      ResourceRequirement:
        coresMax: 1
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
        dockerPull: potato55/hydromt-demo:stac #potato55/hydromt-test:buildfix
        dockerOutputDirectory: /hydromt
      ResourceRequirement:
        coresMax: 1
        ramMax: 2048
      NetworkAccess:
        class: NetworkAccess
        networkAccess: true

  - class: Workflow
    id: hydromt-workflow
    requirements:
      - class: StepInputExpressionRequirement
      - class: InlineJavascriptRequirement
    inputs:
      - id: res
        type: float
      - id: precip_fn
        type: string
      - id: region
        type: string
      - id: catalog
        type: File
    outputs:
      - id: model
        type: Directory
        outputSource: build-hydromt/model
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
        out: [model]
        run: '#build-hydromt'