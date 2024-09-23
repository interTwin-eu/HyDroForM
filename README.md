# Introduction

![CWL](https://img.shields.io/badge/-CWL-1DA1F2.svg)
![Docker](https://img.shields.io/badge/-Docker-2496ED.svg)
![Julia](https://img.shields.io/badge/-Julia-9558B2.svg)
![Python](https://img.shields.io/badge/-Python-3776AB.svg)
![OpenEO](https://img.shields.io/badge/-OpenEO-68A063.svg)

This repository contains the code and documentation for a hydrological model usecase \
for the InterTwin project. The usecase is based on utilizing HydroMT and Wflow to \
simulate hydrological processes in the Adige river basin.

**Relevant links:** \
[InterTwin project](https://www.intertwin.eu/) \
[HydroMT](https://deltares.github.io/hydromt/latest/) \
[Wflow](https://deltares.github.io/Wflow.jl/stable/)

The aim of this usecase is to demostrate the integration of HydroMT and Wflow as a \
self contained OGC Application Package. The OGC Application Package is a standard \
for packaging and distributing geospatial applications.

Each application package is a self-contained directory that contains all the necessary \
files and metadata to run the application. The application package includes a CWL \
workflow, input parameters, and metadata files.

## Table of Contents

- [Introduction](#introduction)
- [Table of Contents](#table-of-contents)
- [Model description](#model-description)
  - [HydroMT](#hydromt)
    - [HydroMT Required inputs](#hydromt-required-inputs)
    - [params.yaml](#paramsyaml)
    - [Building the HydroMT image](#building-the-hydromt-image)
  - [Wflow](#wflow)
    - [Wflow Required inputs](#wflow-required-inputs)
    - [params-wflow.yaml](#params-wflowyaml)
    - [Building the Wflow image](#building-the-wflow-image)
    - [Run Wflow model in container](#run-wflow-model-in-container)
    - [TODO: Update Wflow model](#todo-update-wflow-model)
- [TODO: Surrogate](#todo-surrogate)
- [Parameter Learning](#parameter-learning)
- [HydroMT and Wflow as OGC Application Packages](#hydromt-and-wflow-as-ogc-application-packages)
  - [HydroMT Application Package](#hydromt-application-package)
  - [Wflow Application Package](#wflow-application-package)
  - [TODO Juraj](#todo-juraj)

## Model description

### HydroMT

HydroMT (Hydro Model Tools) is an open-source Python package that facilitates the process of building and analyzing spatial geoscientific models with a focus on water system models. It does so by automating the workflow to go from raw data to a complete model instance which is ready to run and to analyse model results once the simulation has finished. HydroMT builds on the latest packages in the scientific and geospatial python eco-system including xarray, rasterio, rioxarray, geopandas, scipy and pyflwdir. Source: [Deltares HydroMT](https://deltares.github.io/hydromt/latest/)

#### HydroMT Required inputs

`1. region` \
`2. setupconfig` \
`3. catalog` \
`4. volume_data`

#### params.yaml

The `params.yaml` file contains the definitions of the required inputs for the HydroMT application. The user can specify the region by providing a bounding box.

The `setupconfig` is a configuration file for setting up the model resolution, time range etc.

The `catalog` is a HydroMT catalog which provides references to all of the datasets used in the model. **Note**: The catalog is going to be replaced by STAC catalog in the future.

The `volume_data` is the directory mounted to the docker container. It contains the output of the HydroMT application.

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

#### Building the HydroMT image

The HydroMT image is built using the following command and can be found in the `/experimental/hydromt` directory:

```zsh
./docker_build_and_publish.sh
```

The script automatically builds the image and publishes it to the eurac registry.

### Wflow

Wflow is Deltares’ solution for modelling hydrological processes, allowing users to account for precipitation, interception, snow accumulation and melt, evapotranspiration, soil water, surface water and groundwater recharge in a fully distributed environment. Successfully applied worldwide for analyzing flood hazards, drought, climate change impacts and land use changes, wflow is growing to be a leader in hydrology solutions. Wflow is conceived as a framework, within which multiple distributed model concepts are available, which maximizes the use of open earth observation data, making it the hydrological model of choice for data scarce environments. Based on gridded topography, soil, land use and climate data, wflow calculates all hydrological fluxes at any given grid cell in the model at a given time step. Source: [Deltares Wflow](https://deltares.github.io/Wflow.jl/stable/)

#### Wflow Required inputs

`1. runconfig` \
`2. forcings.nc` \
`3. hydromtdata` \
`4. volume data` \
`5. staticmaps.nc`

**Note**: The outputs of HydroMT are used as inputs to Wflow.

#### params-wflow.yaml

The `params-wflow.yaml` file contains the definitions of the required inputs for the Wflow application. The user needs to specify the following inputs. Similarly to HydroMT, these inputs can be described in a `yaml file`:
  
  ```yaml
  runconfig:
    class: File
    path: path/to/wflow_sbm.toml
  forcings:
    class: File
    path: path/to/forcings.nc
  hydromtdata:
    class: Directory
    path: path/to/hydromt_data.yaml
  volume_data:
    class: Directory
    path: path/to/mnt/CEPH_PROJECTS/InterTwin/Wflow/data
  staticmaps:
    class: File
    path: path/to/staticmaps.nc
  ```

#### Building the Wflow image

The Wflow image is built using the following command and can be found in the `/experimental/wflow` directory:

```zsh
./docker_build_and_publish.sh
```

#### TODO: Update Wflow model

Once the model is built, there may be a need to update the original configuration. For example changing land cover or forcings, or updating some model parameters.
When updating the model, the user should be able to select whether to overwrite the current model or not, then creating a new model.

`docker run -v /mnt/CEPH_PROJECTS/InterTwin/hydrologic_data:/data -v /mnt/CEPH_PROJECTS/InterTwin/workflows/wflow:/model -it --rm intertwin:hydromt build --overwrite`

#### Run Wflow model in container

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

## HydroMT and Wflow as OGC Application Packages

This section describes how the HydroMT and Wflow applications are packaged as OGC \
Application Packages.

### HydroMT Application Package

The HydroMT Application Package is available in the following directory: \
`/experimental/hydromt/`

HydroMT process diagram:

![HydroMT CWL workflow](/images/hydromt_workflow.png)

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

Wflow process diagram:

![Wflow CWL workflow](/images/wflow_workflow.png)

The following inputs as described in the params-exp-wflow.yaml file are required to run the Wflow application:

`1. runconfig` \
`2. forcings` \
`3. hydromtdata` \
`4. volume_data` \
`5. staticmaps`

Wflon be run from the command line using the following command from the `/experimental/wflow/cwl/` directory:

```zsh
cwltool --outdir ./wflow-output --no-read-only --no-match-user wflow-run.cwl#run-wflow params-wflow.yaml
```

The output of the Wflow application package is a set of hydrological variables. The output directory can be customized using the `--outdir` flag.

### TODO Juraj

- [] Produce the outputs of HydroMT and Wflow on the eurac filesystem as a showcase
- [] Test these out on the EOEPCA ADES



## Testing

- HydroMT 

`cd HyDroForM && ./tests/test_hydromt.sh`

- Wflow
Requires running HydroMT test to produce outputs in the ./tests/tmp folder

Note: The containers are running as root and the folder and data in ./tests/tmp will be
owned by root, therefore you can't write or execute anything there. As an interim solution
before figuring out how to run the container with a non-root user, after running test_hydromt.sh
and before running test_wflow.sh remember to change ownership of the files to your user and group.

`cd HyDroForM && ./tests/test_wflow.sh`

- Itwinai-hython surrogate training

NOTE: if you are running the test on a VM, remember to install this library https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html

`cd HyDroForM && ./tests/test_surrogate.sh`







