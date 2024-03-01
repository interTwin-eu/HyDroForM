cwlVersion: v1.2
$graph:
  - id: hydromt-build-workflow
    class: Workflow
    inputs:
      - id: region
        type: string
      - id: setupconfig
        type: File
      - id: catalog
        type: File
      - id: volume_data
        type: Directory
    outputs:
      - id: output
        outputSource:
          - hydromt-build_step/output
        type: Directory
    steps:
      - id: hydromt-build_step
        in:
          - id: region
            source:
              - region
          - id: setupconfig
            source:
              - setupconfig
          - id: catalog
            source:
              - catalog
          - id: volume_data
            source:
              - volume_data
        out:
          - output
        run: '#hydromt-build'
        requirements:
          DockerRequirement:
            dockerPull: gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:hydromt
    doc: workflow to build the HydroMT model
    requirements:
      InitialWorkDirRequirement:
        listing:
          - entryname: /data
            entry: $(inputs.volume_data)
  - id: hydromt-build
    class: CommandLineTool
    baseCommand:
      - build
    arguments: []
    doc: Build the HydroMT model
    inputs:
      - id: region
        label: Region/area of interest
        type: string
        inputBinding:
          position: 1
      - id: setupconfig
        label: configuration file
        type: File
        inputBinding:
          position: 2
      - id: catalog
        label: HydroMT data catalog
        type: File
        inputBinding:
          position: 3
      - id: volume_data
        doc: Mounted volume for data
        type: Directory
        inputBinding:
          position: 4
    outputs:
      - id: output
        type: Directory
        outputBinding:
          glob: .
    requirements:
      DockerRequirement:
        dockerPull: gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:hydromt
        dockerOutputDirectory: /output
      InitialWorkDirRequirement:
        listing:
          - entryname: /data
            entry: $(inputs.volume_data)
$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.0.1
s:dateCreated: '2024-02-21'
s:codeRepository: https://gitlab.inf.unibz.it/REMSEN/InterTwin-wflow-app
s:author:
  - s:name: Iacopo Ferrario
    s:email: iacopofederico.ferrario@eurac.edu
    s:affiliation: Hydrology magician
  - s:name: Juraj Zvolensky
    s:email: juraj.zvolensky@eurac.edu
    s:affiliation: CWL enthusiast
