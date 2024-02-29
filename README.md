# Instruction

## HydroMT

>Inputs:
>- data catalog
>- setup file
>- region
>
>Outputs:
>- WFLOW's model directory with required data and config file to run WFLOW
>
>User Parameters:
>- MODELNAME
>- ...
>
>Volumes:
>- v1: data catalog
>- v2: model directory, the model will be saved in a subdirectory  \<MODELNAME\> in /model directory...


### Build and publish Hydromt image to eurac registry

`cd hydromt`

`./docker_build_and_publish.sh`

### Required inputs

### params.yaml

```yaml
region: "{'subbasin':[ 11.4750, 46.8717 ], 'strord':3}"
setupconfig:
  class: File
  path: wflow.ini
catalog: 
  class: File
  path: hydromt_data.yaml
volume_data: 
  class: Directory
  path: /mnt/CEPH_PROJECTS/InterTwin/Wflow/data
```

`cwltool -w output.json hydromt-build.cwl params.yaml`

### Build Wflow model

`docker run -v /mnt/CEPH_PROJECTS/InterTwin/hydrologic_data:/data -v /mnt/CEPH_PROJECTS/InterTwin/workflows/wflow:/model -it --rm intertwin:hydromt build`



### Update Wflow model 

Once the model is built, there may be a need to update the original configuration. For example changing land cover or forcings, or updating some model parameters.
When updating the model, the user should be able to select whether to overwrite the current model or not, then creating a new model. 

`docker run -v /mnt/CEPH_PROJECTS/InterTwin/hydrologic_data:/data -v /mnt/CEPH_PROJECTS/InterTwin/workflows/wflow:/model -it --rm intertwin:hydromt build --overwrite`

### Publish

`docker build -t gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:hydromt .`
`docker push gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:hydromt`

## Wflow

>Inputs: (all produced by HydroMT)
>- config file
>- staticmaps.nc
>- forcings.nc
>- state.nc (optional)
>
>Outputs:
>- hydrological variables
>
>User Parameters: 
>- Warm-up period 
>- ... 
>
>Volumes:
>- v1: model directory, corresponding subdirectory <MODELNAME> as created by HydroMT

`cd wflow`

### Build Wflow app image

`./docker_build_and_update.sh`

### Run Wflow model in container 

`docker run -v $HOME/dev/InterTwin-wflow-app/hydromt/cwl/81iegmjn/model:/data -it --rm gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:wflow run_wflow wflow_sbm.toml`

`cd wflow/cwl`


`cwltool --no-read-only --no-match-user wflow-run.cwl params_wflow.yaml`


## Surrogate

>Inputs:
>- WFLOW's parameters
>- WFLOW's forcings
>- WFLOW's outputs (surrogate training target)
>
>Outputs:
>- trained weights
>
>User Parameters:
>- set of WFLOW's parameters 
>
>Volumes:
>- v1: data catalog
>- v2: WFLOW's model directory, in subdirectory <MODELNAME/surrogate>


TBD

## Parameter Learning

TBD


# TODO

- [] Diagram 
- [] CWL workflow
- [] OpenEO processes
- [] HydroMT reads and writes to STAC
- [] Surrogate components
- [] Parameter Learning component
