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

## CWL updates

I have created a new folder structure for running the HydroMT and WFLOW demo. \
The main folder `hydromt-wflow-demo` contains the `hydromt` and `wflow` folders. \
The `hydromt` folder contains the CWL files for running the HydroMT workflow. \
The `wflow` folder contains the CWL files for running the WFLOW workflow. \
Otherwise it is the same as before.

The `HydroMT` CWL can be found in:
`hydromt-wflow-demo/hydromt/cwl/run_hydromt.cwl`

The `WFLOW` CWL can be found in:
`hydromt-wflow-demo/wflow/cwl/wflow-run.cwl`

I tried a bunch of CWLs for Wflow without any major success. \
The latest one is one of the simpler ones I tried. \
I need to go over it to see what the f is going on. 

### Run HydroMT

to run HydroMT you would do the following:

```zsh
cd hydromt-wflow-demo/hydromt/cwl
cwltool --outdir ./hydromt-output run_hydromt.cwl#hydromt-build params.yaml
```

The HydroMT process is fully functional in CWL.

### Run Wflow

(Functional) To run Wflow in a docker container without CWL:

 ```zsh
 docker run -v /home/jzvolensky/eurac/projects/InterTwin-wflow-app/hydromt-wflow-demo/hydromt/cwl/hydromt-output/99qvg3ki/model:/data -w /data -it --rm gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:wflow run_wflow wflow_sbm.toml
```

("Work in Progress" but more like work and no progress) To run Wflow via CWL:

```zsh
 cwltool  --outdir ./wflow-output --no-read-only --debug --relax-path-checks wflow-run.cwl#wflow-build params_wflow.yaml > output.json
```

Alternative CWL execution engine [Toil](https://toil.readthedocs.io/en/latest/cwl/introduction.html):

I explored another CWL execution to see if it would work better than cwltool. \
spoiler alert, it does not.

```zsh
 toil-cwl-runner --outdir ./wflow-output wflow-run.cwl#wflow-build params_wflow.yaml
```

*Note*: Currently fails due to the Julia environment not being correctly setup and missing packages. \
This is likely due to the restrictive nature of the CWL execution environment. \
The CWL runners run a bunch of configurations and volume mounts, temporary directories, etc. \
This is likely causing the Julia environment to not be correctly setup. \
My disappointment is immeasurable and my day is ruined.
