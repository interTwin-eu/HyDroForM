cwlVersion: v1.2
$graph:
  - class: Workflow
    id: workflow-build
    inputs:
      - id: runconfig
        type: File
      - id: volume_data
        type: Directory
    outputs:
      - id: workflow-output
        outputSource:
          - wflow-build_step/output
        type: Directory
    steps:
      - id: wflow-build_step
        in:
          - id: runconfig
            source:
              - runconfig
          - id: volume_data
            source:
              - volume_data
        out:
          - output
        run: '#wflow-build'
  - id: wflow-build
    class: CommandLineTool
    baseCommand: ["/usr/bin/env", "-S", "julia", "--project=/env", "/usr/bin/run_wflow"]
    inputs:
      - id: runconfig
        type: File
        inputBinding:
          position: 1
      - id: volume_data
        type: Directory
    outputs:
      - id: output
        type: Directory
        outputBinding:
          glob: $(runtime.outdir)
    requirements:
      DockerRequirement:
        dockerPull: gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:wflow
        dockerFile: |
          FROM gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:wflow
          VOLUME /data
      NetworkAccess:
        class: NetworkAccess
        networkAccess: true
      InitialWorkDirRequirement:
        listing:
          - entry: $(inputs.volume_data)
            entryname: /data
          - entry: '/data/log.txt'
            entryname: 'log.txt'
$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.0.1
s:dateCreated: '2024-02-27'
s:codeRepository: https://gitlab.inf.unibz.it/REMSEN/InterTwin-wflow-app
s:author:
  - s:name: Iacopo Ferrario
    s:email: iacopofederico.ferrario@eurac.edu
    s:affiliation: Hydrology magician
  - s:name: Juraj Zvolensky
    s:email: juraj.zvolensky@eurac.edu
    s:affiliation: CWL enthusiast


