#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: CommandLineTool
id: hydromt-build

requirements:
    DockerRequirement:
        dockerPull: gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:hydromt
        dockerOutputDirectory: /output
    InitialWorkDirRequirement:
        listing:
            - entry: $(inputs.volume_data)
              entryname: /data

baseCommand: build
arguments: []

inputs:
    region:
        type: string
        inputBinding:
            position: 1
    setupconfig:
        type: File
        inputBinding:
            position: 2
    catalog: # THIS WILL BE A URL POINTING TO STAC OR A CATALOG.JSON
        type: File
        inputBinding:
            position: 3
    volume_data:
        type: Directory
        inputBinding:
            position: 4

outputs: # THIS CONTROLS THE JSON OUPUT
    output:
        outputBinding:
            glob: .
        type: Directory

