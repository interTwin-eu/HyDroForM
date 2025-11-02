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
        dockerPull: potato55/hydromt-demo:stac
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
      - id: staticmaps
        type: File
        outputBinding:
          glob: "model/staticmaps.nc"
      - id: forcings
        type: File
        outputBinding:
          glob: "model/forcings.nc"
    requirements:
      DockerRequirement:
        dockerPull: potato55/hydromt-demo:stac
        dockerOutputDirectory: /hydromt
      ResourceRequirement:
        coresMax: 1
        ramMax: 2048
      NetworkAccess:
        class: NetworkAccess
        networkAccess: true

  - class: CommandLineTool
    id: save-to-stac
    baseCommand: ["python3", "/usr/bin/stac.py"]
    inputs:
      - id: staticmaps
        type: File
        inputBinding:
          prefix: "--staticmaps_path"
          position: 1
      - id: forcings
        type: File
        inputBinding:
          prefix: "--forcings_path"
          position: 2
      - id: output_dir
        type: Directory
        inputBinding:
          prefix: "--output_dir"
          position: 3
    outputs:
      - id: output_stac
        type: Directory
        outputBinding:
          glob: "*"
    requirements:
      DockerRequirement:
        dockerPull: potato55/hydromt-demo:stac
        dockerOutputDirectory: /hydromt
      InitialWorkDirRequirement:
        listing:
          # - entryname: model/output_stac
          #   entry: "model/output_stac"
          #   writable: true
          - entryname: model
            entry: $(inputs.output_dir.path)
            writable: true
          # - entryname: model/STAC
          #   entry: "model/STAC"
          #   writable: true
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
      - id: staticmaps
        type: File
        outputSource: build-hydromt/staticmaps
      - id: forcings
        type: File
        outputSource: build-hydromt/forcings
      - id: output_stac
        type: Directory
        outputSource: save-to-stac/output_stac
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
        out: [model, staticmaps, forcings]
        run: '#build-hydromt'
      - id: save-to-stac
        in:
          - id: staticmaps
            source: build-hydromt/staticmaps
          - id: forcings
            source: build-hydromt/forcings
          - id: output_dir
            source: build-hydromt/model
        out: [output_stac]
        # out: [json_collection, json_items]
        run: '#save-to-stac'
