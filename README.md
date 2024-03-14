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
- [HydroMT](#hydromt)
  - [HydroMT inputs](#hydromt-inputs)
  - [HydroMT outputs](#hydromt-outputs)
  - [HydroMT CLI](#hydromt-cli)
  - [Build and publish Hydromt image to eurac registry](#build-and-publish-hydromt-image-to-eurac-registry)
  - [params.yaml](#paramsyaml)
  - [Build Wflow model](#build-wflow-model)
  - [Publish](#publish)
- [Wflow](#wflow)
  - [Wflow inputs](#wflow-inputs-all-produced-by-hydromt)
  - [Wflow outputs](#wflow-outputs)
  - [Data Volumes](#data-volumes)
  - [Building the Wflow image](#building-the-wflow-image)
  - [Run Wflow model in container](#run-wflow-model-in-container)
- [(WIP) HydroMT and Wflow as OGC Application Packages](#wip-hydromt-and-wflow-as-ogc-application-packages)
  - [HydroMT Application Package](#hydromt-application-package)
  - [Wflow Application Package](#wflow-application-package)

## HydroMT

HydroMT (Hydro Model Tools) is an open-source Python package that facilitates the process of building and analyzing spatial geoscientific models with a focus on water system models. It does so by automating the workflow to go from raw data to a complete model instance which is ready to run and to analyse model results once the simulation has finished. HydroMT builds on the latest packages in the scientific and geospatial python eco-system including xarray, rasterio, rioxarray, geopandas, scipy and pyflwdir. Source: [Deltares HydroMT](https://deltares.github.io/hydromt/latest/)

### HydroMT inputs

1. `data_catalog.yaml`: describes the name and metadata of data collections \
2. `wflow_init.yaml`: declares which collection from data_catalog.yaml to use and model setup options \
3. `region`: this is an argument to pass to **HydroMT CLI** that defines the region of interest

### HydroMT outputs

1. Directory with required data and config file to run [Wflow](#wflow)

### HydroMT CLI

`hydromt build wflow -r "{'subbasin':[ 11.4750, 46.8717 ], 'strord':3}" -d data_catalog.yaml -i wflow_init.yaml`

Data volumes: \
`1. v1: data catalog` \
`2. v2: model directory, the model will be saved in a subdirectory  \<MODELNAME\> in /model directory...`

### Build and publish Hydromt image to eurac registry

The HydroMT image is built using the following command and can be found in the `/experimental/hydromt` directory:

```zsh
./docker_build_and_publish.sh
```

The script automatically builds the image and publishes it to the eurac registry.

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

### Publish

`docker build -t gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:hydromt .`
`docker push gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:hydromt`

## Wflow

Wflow is Deltares’ solution for modelling hydrological processes, allowing users to account for precipitation, interception, snow accumulation and melt, evapotranspiration, soil water, surface water and groundwater recharge in a fully distributed environment. Successfully applied worldwide for analyzing flood hazards, drought, climate change impacts and land use changes, wflow is growing to be a leader in hydrology solutions. Wflow is conceived as a framework, within which multiple distributed model concepts are available, which maximizes the use of open earth observation data, making it the hydrological model of choice for data scarce environments. Based on gridded topography, soil, land use and climate data, wflow calculates all hydrological fluxes at any given grid cell in the model at a given time step. Source: [Deltares Wflow](https://deltares.github.io/Wflow.jl/stable/)

### Wflow inputs (all produced by HydroMT)

`1. config file` \
`2. staticmaps.nc` \
`3. forcings.nc` \
`4. state.nc` **(optional)**

#### Wflow outputs

`1.hydrological variables` \
`2. User Parameters:` \
`3. Warm-up period` \

#### Data Volumes

`1. v1: model directory, corresponding subdirectory <MODELNAME> as created by HydroMT`

#### Building the Wflow image

The Wflow image is built using the following command and can be found in the `/experimental/wflow` directory:

```zsh
./docker_build_and_publish.sh
```

### Run Wflow model in container

`docker run -v $HOME/dev/InterTwin-wflow-app/hydromt/cwl/81iegmjn/model:/data -it --rm gitlab.inf.unibz.it:4567/remsen/cdr/climax/meteo-data-pipeline:wflow run_wflow wflow_sbm.toml`

`cd wflow/cwl`

`cwltool --no-read-only --no-match-user wflow-run.cwl params_wflow.yaml`

## (WIP) HydroMT and Wflow as OGC Application Packages

This section describes how the HydroMT and Wflow applications are packaged as OGC \
Application Packages. The OGC Application Package is a standard for packaging and \
distributing geospatial applications.

Each application package is a self-contained directory that contains all the necessary \
files and metadata to run the application. The application package includes a CWL \
workflow, input parameters, and metadata files. The application package can be \

### HydroMT Application Package

This section describes how the HydroMT and Wflow applications are packaged as OGC \
Application Packages.

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
