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
    id: save-to-stac
    # baseCommand: to_stac
    # inputs:
    #   - id: staticmaps_out
    #     type: File
    #     inputBinding:
    #       prefix: "--staticmaps_path"
    #       position: 1
    #   - id: forcings_out
    #     type: File
    #     inputBinding:
    #       prefix: "--forcings_path"
    #       position: 2
    baseCommand: ["python3", "/usr/bin/stac.py"]
    inputs:
      - id: staticmaps_out
        type: File
        inputBinding:
          prefix: "--staticmaps_path"
          position: 1
          valueFrom: $(self.path)
      - id: forcings_out
        type: File
        inputBinding:
          prefix: "--forcings_path"
          position: 2
          valueFrom: $(self.path)
    outputs:
      - id: json_collection
        type: File
        outputBinding:
          glob: "WFLOW_FORCINGS_STATICMAPS/*.json"
      - id: json_items
        type: File[]
        outputBinding:
          glob: "WFLOW_FORCINGS_STATICMAPS/items/*.json"
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
      - id: staticmaps_out
        type: File
        outputBinding:
          glob: "model/staticmaps.nc"
      - id: forcings_out
        type: File
        outputBinding:
          glob: "model/forcings.nc"
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
      - id: staticmaps_out
        type: File
        outputSource: build-hydromt/staticmaps_out
      - id: forcings_out
        type: File
        outputSource: build-hydromt/forcings_out
      - id: json_collection
        type: File
        outputSource: save-to-stac/json_collection
      - id: item_jsons
        type: File[]
        outputSource: save-to-stac/json_items
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
        out: [model, staticmaps_out, forcings_out]
        run: '#build-hydromt'
      - id: save-to-stac
        in:
          - id: staticmaps_out
            source: build-hydromt/staticmaps_out
          - id: forcings_out
            source: build-hydromt/forcings_out
        out: [json_collection, json_items]
        run: '#save-to-stac'