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
  - s:name: HyDroForM
  - s:description: |
      Hydrological Data Forecasting model. This model is designed to 
      provide accurate forecasts of hydrological data based on a variety 
      of input parameters. It uses advanced machine learning algorithms 
      to predict future data trends and can be used in a variety of 
      hydrological research contexts. It is based on HydroMT by Deltares.

cwlVersion: v1.2
$graph:
  - id: hydromt-build-workflow
    doc: |
      This workflow builds the HydroMT model using the provided configuration
      file and data catalog. It first updates the configuration file based on
      the user inputs and then builds the model using the updated configuration 
      file.
    class: Workflow
    inputs:
      - id: region
        type: string
      - id: setupconfig
        type: File
      - id: catalog
        type: File
      - id: config_gen
        type: File
      - id: volume_data
        type: Directory
      - id: res
        type: float?
      - id: precip_fn
        type: string?
    outputs:
      - id: output
        outputSource:
          - hydromt-build_step/output
        type: Directory
    steps:
      - id: config_gen_step
        in:
          - id: res
            source:
              - res
          - id: precip_fn
            source:
              - precip_fn
          - id: setupconfig
            source:
              - setupconfig
          - id: config_gen
            source:
              - config_gen
          # - id: volume_data
          #   source:
          #     - volume_data
        out:
          - hydromt_config
        run: update-config.cwl
      - id: hydromt-build_step
        in:
          - id: region
            source:
              - region
          - id: setupconfig
            source:
              - config_gen_step/hydromt_config
          - id: config_gen
            source:
              - config_gen
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
      InitialWorkDirRequirement:
        listing:
          - entryname: /data
            entry: $(inputs.volume_data)
  - id: hydromt-build
    class: CommandLineTool
    baseCommand:
      - build
    arguments: []
    doc: |
      This tool builds the HydroMT model using the provided configuration file
      and data catalog.
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
      - id: config_gen
        label: Script to update config file
        type: File
        inputBinding:
          position: 4
      - id: volume_data
        doc: Mounted volume for data
        type: Directory
        inputBinding:
          position: 5
    outputs:
      - id: output
        type: Directory
        outputBinding:
          glob: .
    requirements:
      DockerRequirement:
        dockerPull: potato55/hydromt:expython
        dockerOutputDirectory: /hydromt
      InitialWorkDirRequirement:
        listing:
          - entryname: /data
            entry: $(inputs.volume_data)
      NetworkAccess:
        class: NetworkAccess
        networkAccess: true
          
