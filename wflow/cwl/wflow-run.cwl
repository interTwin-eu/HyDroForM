#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: CommandLineTool
id: wflow-run

requirements:
    NetworkAccess:
        class: NetworkAccess
        networkAccess: true
    DockerRequirement:
        dockerPull: gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:wflow
        dockerOutputDirectory: /output
    InitialWorkDirRequirement:
        listing:
            - entry: $(inputs.volume_data)
              entryname: /data

baseCommand: run_wflow
arguments: []

inputs:
    runconfig:
        type: File
        inputBinding:
            position: 1
    volume_data:
        type: Directory
        inputBinding:
            position: 2

outputs:
    output:
        outputBinding:
            glob: .
        type: Directory
