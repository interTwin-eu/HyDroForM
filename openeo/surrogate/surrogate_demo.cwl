cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.9.9
s:dateCreated: '2024-10-17'
s:keywords: Hydrology, EO, CWL, AP, InterTwin, Magic
s:codeRepository: 
s:author:
  - s:name: Iacopo Federico Ferrario
    s:email: iacopofederico.ferrario@eurac.edu
    s:affiliation: Hydrology Magician
  - s:name: Juraj Zvolensky
    s:email: juraj.zvolensky@eurac.edu
    s:affiliation: CWL Enthusiast

$graph:
  - class: CommandLineTool
    id: exec-itwinai
    baseCommand: ["itwinai", "exec-pipeline"]
    arguments: []
    inputs:
      - id: config
        type: File
        inputBinding:
          position: 1
          prefix: "--config"
          valueFrom: $(self.basename)
      - id: pipe-key
        type: string
        inputBinding:
          position: 2
          prefix: "--pipe-key"
          valueFrom: $(inputs.pipe-key)
    outputs:
      - id: output
        type: stdout
    requirements:
      DockerRequirement:
        dockerPull: potato55/surrogate-test:latest
      ResourceRequirement:
        coresMax: 4
        ramMax: 25000
      NetworkAccess:
        class: NetworkAccess
        networkAccess: true
  - class: Workflow
    id: surrogate-demo
    requirements:
      - class: StepInputExpressionRequirement
    inputs:
      - id: config
        type: File
      - id: pipe-key
        type: string
    outputs:
      - id: output
        type: stdout
    steps:
      - id: exec-itwinai
        in: 
          config: config
          pipe-key: pipe-key
        out: [output]
        run: '#exec-itwinai'

