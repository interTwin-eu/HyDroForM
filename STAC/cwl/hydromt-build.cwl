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
  - id: hydromt-workflow
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
      - id: res
        type: float?
      - id: precip_fn
        type: string?
      - id: volume_data
        type: Directory
    outputs:
      - id: output
        outputSource:
          - hydromt-build-model_step/output
        type: Directory
    steps:
      - id: config-generator_step
        in:
          - id: config_gen
            source:
              - config_gen
          - id: res
            source:
              - res
          - id: precip_fn
            source:
              - precip_fn
        out:
          - hydromt-config
        run: '#config-generator'
      - id: hydromt-build-model_step
        in:
          - id: region
            source:
              - region
          - id: setupconfig
            source:
              - config-generator_step/hydromt-config
          - id: catalog
            source:
              - catalog
          - id: volume_data
            source:
              - volume_data
        out:
          - output
        run: '#hydromt-build-model'
    requirements:
      DockerRequirement:
        dockerPull: potato55/hydromt:expython
        dockerOutputDirectory: /hydromt
      # InlineJavascriptRequirement: {}
      InitialWorkDirRequirement:
        listing:
          - $(inputs.setupconfig)
          - entryname: workdir 
            entry: /hydromt
            writable: true
      NetworkAccess:
        class: NetworkAccess
        networkAccess: true
    doc: Full workflow of HydroMT which first generates updated config and then builds the model
  - id: hydromt-build-model
    class: CommandLineTool
    baseCommand:
      - build
    arguments: []
    doc: Tool used to build the HydroMT model from the provided input files
    inputs:
      - id: region
        label: Region of interest
        doc: 'Region of interest in the format of: {''subbasin'': [11.69, 46.666]}'
        type: string
        inputBinding:
          position: 1
      - id: setupconfig
        label: wflow.ini configuration file
        doc: Configuration file which provides the build with parameters such as resolution etc.
        type: File
        inputBinding:
          position: 2
      - id: catalog
        label: HydroMT data catalog
        doc: A catalog containing the locations of various datasets used to build the model
        type: File
        inputBinding:
          position: 3
      - id: volume_data
        label: Mounted directory containing data on CEPH
        doc: Data folder to provide the HydroMT build with the necessary datasets
        type: Directory
        inputBinding:
          position: 4
    outputs:
      - id: output
        label: Output of the HydroMT build command
        doc: This tool generates a couple of different outputs such as wflow configuration, forcings.nc and static geojson maps
        type: Directory
        outputBinding:
          glob: . 
    requirements:
      DockerRequirement:
        dockerPull: potato55/hydromt:expython
        dockerOutputDirectory: /hydromt
  - id: config-generator
    class: CommandLineTool
    baseCommand:
      - python3
    doc: Step necessary to update the wflow.ini configuration with the user provided input
    inputs:
      - id: config_gen
        label: Configuration generator script
        type: File
        inputBinding:
          position: 1
      - id: res
        label: Desired resolution of the model
        type: float?
        inputBinding:
          position: 2
      - id: precip_fn
        label: Choose between two possible datasets
        type: string?
        inputBinding:
          position: 3
    outputs:
      - id: hydromt-config
        label: Output wflow.ini configuration files used in the HydroMT build step
        type: File
        outputBinding:
          glob: wflow.ini
    requirements:
      DockerRequirement:
        dockerPull: potato55/hydromt:expython
        dockerOutputDirectory: /hydromt
      InitialWorkDirRequirement:
        listing:
          - $(inputs.config_gen)

          
