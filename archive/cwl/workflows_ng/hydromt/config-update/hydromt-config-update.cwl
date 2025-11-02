cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:codeRepository: https://github.com/jzvolensky/Itwin-tech-meeting
s:dateCreated: 2025-01-30
s:keywords: Hydrology, EO, CWL, AP, InterTwin, Magic
s:softwareVersion: 2.0.0
s:author:
  - s:affiliation: Hydrology Magician
    s:email: iacopofederico.ferrario@eurac.edu
    s:name: Iacopo Federico Ferrario
  - s:affiliation: CWL Enthusiast
    s:email: juraj.zvolensky@eurac.edu
    s:name: Juraj Zvolensky

class: CommandLineTool
id: hydromt-config-update

requirements:
  DockerRequirement:
    dockerPull: potato55/hydromtng:0.1
  NetworkAccess:
    class: NetworkAccess
    networkAccess: true
  ResourceRequirement:
    coresMax: 1
    coresMin: 1
    ramMax: 2048
    ramMin: 2048

inputs:
  res:
    type: float
    inputBinding:
      position: 1
  precip_fn:
    type: string
    inputBinding:
      position: 2

outputs:
  setupconfig:
    type: File
    outputBinding:
      glob: "output/wflow.ini"

baseCommand:
  - bash
  - /hydromt/config-update/update.sh
