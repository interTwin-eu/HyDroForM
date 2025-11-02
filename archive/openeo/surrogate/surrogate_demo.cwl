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
    baseCommand: ["itwinai", "exec-pipeline", "--config", "./use-case/config.yaml"] #/app
    # baseCommand: ["/bin/bash", "-c"]
    # arguments: ["itwinai exec-pipeline --config /usr/src/app/use-case/config.yaml"]
    inputs:
      # - id: config            The config is local in the image
      #   type: string          so we cant really pass it in cwl
      #   inputBinding:         so we just call it from the command
      #     position: 1         In the future replace with a link to the config
      #     prefix: "--config"
      - id: pipe-key
        type: string
        inputBinding:
          position: 1
          prefix: "--pipe-key"
    outputs:
      - id: output
        type: stdout
    requirements:
      DockerRequirement:
        dockerPull: surrogate-test:latest
        dockerOutputDirectory: /usr/src/app
      ResourceRequirement:
        coresMax: 4
        ramMax: 25000
      InlineJavascriptRequirement: {}
      # EnvVarRequirement:
      #   envDef:
      #     - envName: PYTHONPATH
      #       envValue: "/jovyan/.local/lib/python3.10/site-packages:/home"
      NetworkAccess:
        class: NetworkAccess
        networkAccess: true
  - class: Workflow
    id: surrogate-demo
    requirements:
      - class: StepInputExpressionRequirement
      - class: InlineJavascriptRequirement
    inputs:
    #   - id: config
    #     type: string
      - id: pipe-key
        type: string
    outputs:
      - id: output
        type: File
        outputSource: exec-itwinai/output
    steps:
      - id: exec-itwinai
        in:
          # config: config
          pipe-key: pipe-key
        out: [output]
        run: '#exec-itwinai'
