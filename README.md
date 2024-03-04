# Instruction

## HydroMT

**HydroMT** inputs: \
`1. data catalog` \
`2. setup file` \
`3. region`

**HydroMT** outputs:

`1. WFLOW's model directory with required data and config file to run WFLOW`

`2. User Parameters:` \
 MODELNAME
 ADD MORE?

Data volumes: \
`1. v1: data catalog` \
`2. v2: model directory, the model will be saved in a subdirectory  \<MODELNAME\> in /model directory...`

### Build and publish Hydromt image to eurac registry

**Note**: Requires access to eurac registry

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

Wflow inputs: **(all produced by HydroMT)** \
`1. config file` \
`2. staticmaps.nc` \
`3. forcings.nc` \
`4. state.nc` **(optional)**

Wflow outputs: \
`1.hydrological variables` \
`2. User Parameters:` \
`3. Warm-up period` \
Data Volumes: \
`1. v1: model directory, corresponding subdirectory <MODELNAME> as created by HydroMT`

### Build Wflow app image

`cd wflow`

`./docker_build_and_update.sh`

### Run Wflow model in container

`docker run -v $HOME/dev/InterTwin-wflow-app/hydromt/cwl/81iegmjn/model:/data -it --rm gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:wflow run_wflow wflow_sbm.toml`

`cd wflow/cwl`

`cwltool --no-read-only --no-match-user wflow-run.cwl params_wflow.yaml`

## TODO: Surrogate 

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

## (WIP) HydroMT and Wflow as OGC Application Packages

This section describes how the HydroMT and Wflow applications are packaged as OGC \
Application Packages. The OGC Application Package is a standard for packaging and \
distributing geospatial applications.

Each application package is a self-contained directory that contains all the necessary \
files and metadata to run the application. The application package includes a CWL \
workflow, input parameters, and metadata files. The application package can be \

### HydroMT Application Package

The HydroMT Application Package is available in the following directory: \
`/experimental/hydromt/`

The directory contains everything needed to run the HydroMT application. The Dockerfile contains the \
environment setup and dependencies for the HydroMT application. \
The image is automatically pulled from the eurac registry when the application is run.

To execute the HydroMT application, the user needs to provide the following inputs: \
`1. data catalog` \
`2. setup file` \
`3. region`

These can be specified in:
`/experimental/hydromt/cwl/params.yaml`

The HydroMT application package can be executed using the following command from the `/experimental/hydromt/cwl/ directory`:

```zsh
cwltool --outdir ./hydromt-output hydromt-build.cwl#hydromt-build params.yaml
```

**Note**: The `--outdir` flag specifies the output directory for the application package. This can be customized to the user's preference.

### Wflow Application Package

The Wflow Application Package is available in the following directory: \
`/experimental/wflow/`

The following inputs as described in the params-exp-wflow.yaml file are required to run the Wflow application:

`1. runconfig` \
`2. forcings` \
`3. hydromtdata` \
`4. volume_data` \
`5. staticmaps`

Wflon be run from the command line using the following command from the `/experimental/wflow/cwl/` directory:

```zsh
cwltool --outdir ./wflow-output --no-read-only --no-match-user wflow-exp-run.cwl#run-wflow params-exp-wflow.yaml
```

The output of the Wflow application package is a set of hydrological variables. The output directory can be customized using the `--outdir` flag.

**Note**: I still need to figure out why this is working because it is \
a bit of a mystery to me.

### TODO Juraj

- [] Make some nice diagrams for the CWLs to show the workflow logic
- [] Finalize the CWLs
- [] Produce the outputs of HydroMT and Wflow on the eurac filesystem as a showcase
- [] Make a nice README for the HydroMT and Wflow application packages
- [] Test these out on the EOEPCA ADES
