cwlVersion: v1.2
$graph:
  - id: wflow-workflow
    class: Workflow
    label: wfw
    inputs:
      - id: runconfig
        type: File
      - id: forcings
        type: File
      - id: hydromtdata
        type: File
      - id: volume_data
        type: Directory
      - id: staticmaps
        type: File
    outputs:
      - id: netcdf_output
        outputSource:
          - chmod_step/netcdf_output
        type: Directory
    steps:
      - id: run-wflow_step
        in:
          - id: runconfig
            source:
              - runconfig
          - id: forcings
            source:
              - forcings
          - id: hydromtdata
            source:
              - hydromtdata
          - id: volume_data
            source:
              - volume_data
          - id: staticmaps
            source:
              - staticmaps
        out:
          - netcdf_output
        run: '#run-wflow'
        requirements:
          DockerRequirement:
            dockerPull: potato55/wflow
            dockerOutputDirectory: /output
      - id: chmod_step
        in:
          - id: netcdf_output
            source:
              - run-wflow_step/netcdf_output
        out:
          - id: netcdf_output
        run:
          class: CommandLineTool
          baseCommand: ["chmod", "777"]
          inputs:
            - id: netcdf_output
              type: Directory
              inputBinding:
                position: 1
          outputs:
            - id: netcdf_output
              type: Directory
              outputBinding:
                glob: "$(inputs.netcdf_output.path)"
    doc: workflow for wflow
  - id: run-wflow
    class: CommandLineTool
    baseCommand:
      - run_wflow
    label: runwflowmodel
    doc: Run Wflow Model
    inputs:
      - id: runconfig
        type: File
        inputBinding:
          position: 1
      - id: forcings
        type: File
        inputBinding:
          position: 2
      - id: hydromtdata
        type: File
        inputBinding:
          position: 3
      - id: volume_data
        type: Directory
        inputBinding:
          position: 4
      - id: staticmaps
        type: File
        inputBinding:
          position: 5
    outputs:
      - id: netcdf_output
        type: Directory
        outputBinding:
          glob: . 
    requirements:
      DockerRequirement:
        dockerPull: potato55/wflow
        dockerOutputDirectory: /output
      EnvVarRequirement:
        envDef:
          JULIA_DEPOT_PATH: /app/env/repo
          JULIA_PROJECT: /app/env
      InitialWorkDirRequirement:
        listing:
          - $(inputs.runconfig)
          - $(inputs.forcings)
          - $(inputs.hydromtdata)
          - $(inputs.volume_data)
          - $(inputs.staticmaps)
$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.0.1
s:dateCreated: '2024-02-26'
s:codeRepository: https://gitlab.inf.unibz.it/REMSEN/InterTwin-wflow-app
s:author:
  - s:name: Iacopo Ferrario
    s:email: iacopofederico.ferrario@eurac.edu
    s:affiliation: Hydrology magician
  - s:name: Juraj Zvolensky
    s:email: juraj.zvolensky@eurac.edu
    s:affiliation: CWL enthusiast