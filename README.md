# InterTwin HyDroForM

<img src="docs/images/HyDroForM-temp-logo.png" alt="HyDroForM" width="300">

## Table of Contents

## Introduction

HyDroForM stands for "Hydrological Drought Forecasting Model with HydroMT and Wflow". It is a Digital Twin for Drought Early Warning in the Alps developed as a use case for the [InterTwin project](https://www.intertwin.eu/). The details of the use case are also available online [here](https://www.intertwin.eu/intertwin-use-case-a-digital-twin-for-drought-early-warning-in-the-alps).

InterTwin components used in this use case are:

- [OpenEO](https://openeo.org/)
- [raster-to-stac](https://pypi.org/project/raster2stac/)
- [DownscaleML](https://github.com/suriyahgit/downScaleML)
- [openeo-pg-parser-networkx](https://github.com/Open-EO/openeo-pg-parser-networkx)
- [openeo-processes-dask](https://github.com/Open-EO/openeo-processes-dask)
- [HydroMT-Sfincs](https://github.com/Deltares/hydromt_sfincs)
- [ItwinAI](https://github.com/interTwin-eu/itwinai)
- [OSCAR](https://github.com/grycap/oscar)
- [Hython](https://github.com/interTwin-eu/hython)
- [InterLink](https://github.com/interTwin-eu/interLink)

## Environment setup

To develop and test locally, use the provided `environment.yaml` file to create a conda environment:

```bash
conda env create -f environment.yaml
conda activate hydroform
```

## TODO: Use case diagram

## TODO: System design diagram

## Use case components

There are **three main components** in the HyDroForM use case:

### HydroMT

HydroMT (Hydro Model Tools) is an open-source Python package that facilitates the process of building and analyzing spatial geoscientific models with a focus on water system models. It does so by automating the workflow to go from raw data to a complete model instance which is ready to run and to analyse model results once the simulation has finished. HydroMT builds on the latest packages in the scientific and geospatial python eco-system including xarray, rasterio, rioxarray, geopandas, scipy and pyflwdir. Source: [Deltares HydroMT](https://deltares.github.io/hydromt/latest/)

#### Running HydroMT

To run HydroMT from start to finish you can use the `validation` script which is located in `/docker/hydromt/validation.sh`. This script will run the HydroMT validation test which includes the following steps:

1. Update the configuration file of HydroMT
2. Run HydroMT using the configuration file
3. Convert the output Wflow configuration file to lowercase letters
4. Wrap the outputs into STAC collections

### Wflow

Wflow is Deltares’ solution for modelling hydrological processes, allowing users to account for precipitation, interception, snow accumulation and melt, evapotranspiration, soil water, surface water and groundwater recharge in a fully distributed environment. Successfully applied worldwide for analyzing flood hazards, drought, climate change impacts and land use changes, wflow is growing to be a leader in hydrology solutions. Wflow is conceived as a framework, within which multiple distributed model concepts are available, which maximizes the use of open earth observation data, making it the hydrological model of choice for data scarce environments. Based on gridded topography, soil, land use and climate data, wflow calculates all hydrological fluxes at any given grid cell in the model at a given time step. Source: [Deltares Wflow](https://deltares.github.io/Wflow.jl/stable/)

#### Running Wflow

### TODO: Surrogate model

## OSCAR

OSCAR is an open-source platform to support the event-driven serverless computing model for data-processing applications. It can be automatically deployed on multi-Clouds, and even on low-powered devices, to create highly-parallel event-driven data-processing serverless applications along the computing continuum. These applications execute on customized runtime environments provided by Docker containers that run on elastic Kubernetes clusters. It is also integrated with the SCAR framework, which supports a High Throughput Computing Programming Model to create highly-parallel event-driven data-processing serverless applications that execute on customized runtime environments provided by Docker containers run on AWS Lambda and AWS Batch. [OSCAR](https://github.com/grycap/oscar)

## Tests

The components of the use case are set up in `Docker containers`. We have a set of scripts available to build and run the base images. These can be found in the `/tests` directory and can be run from `root` directory of the repository.

For example:

```bash
./tests/test_hydromt.sh
```

## TODO: Use case demonstration

## License

This project is licensed under the Apache 2.0 - see the [LICENSE](LICENSE) file for details.
