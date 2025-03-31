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
    id: convert-lowercase
    baseCommand: fix_wflow_sbm
    inputs:
      - id: runconfig
        type: File
        inputBinding:
          position: 1
          valueFrom: $(self.basename)
    outputs:
      - id: runconfig-fixed
        type: File
        outputBinding:
          glob: "wflow_sbm.toml"
    requirements:
      DockerRequirement:
        dockerPull: potato55/wflow-demo:latest 
        dockerOutputDirectory: /output
      InitialWorkDirRequirement:
        listing:
          - entryname: $(inputs.runconfig.basename)
            entry: $(inputs.runconfig)
            writable: true
      ResourceRequirement:
        coresMax: 1
        ramMax: 2048
      NetworkAccess:
        class: NetworkAccess
        networkAccess: true
  
  - class: CommandLineTool
    id: run-wflow
    baseCommand: [bash, "-c"]
    arguments:
      - |
        echo "Starting run-wflow step"
        echo "Input runconfig path: $(inputs.runconfig.path)"
        echo "Listing contents of /output:"
        ls -l /output
        run_wflow $(inputs.runconfig.path) $(inputs.forcings.path) $(inputs.hydromtdata.path) $(inputs.volume_data.path) $(inputs.staticmaps.path)
        echo "Completed run-wflow step"
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
        dockerPull: potato55/wflow-demo:latest
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
  - class: Workflow
    id: wflow-workflow
    requirements:
      - class: StepInputExpressionRequirement
      - class: InlineJavascriptRequirement
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
        type: Directory
        outputSource: run-wflow/netcdf_output
    steps:
      - id: convert-lowercase
        in:
          - id: runconfig
            source: runconfig
        out: [runconfig-fixed]
        run: '#convert-lowercase'
      - id: run-wflow
        in:
          - id: runconfig
            source: convert-lowercase/runconfig-fixed
          - id: forcings
            source: forcings
          - id: hydromtdata
            source: hydromtdata
          - id: volume_data
            source: volume_data
          - id: staticmaps
            source: staticmaps
        out: [netcdf_output]
        run: '#run-wflow'