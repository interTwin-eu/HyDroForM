# Official Changelog

## Purpose

Since we are working on 1 branch now and my commit messages are getting \
ridiculously long, I thought it would be a good idea to start a changelog.

## 04/03/2024 (WIP) HydroMT and Wflow as OGC Application Packages

I have been working on packaging Wflow so that it can run as an OGC Application via a CWL workflow.

### Fixes

#### HydroMT

- Finalized the CWL workflow for the HydroMT application package.
  - This can now be found in `/experimental/hydromt/cwl/hydromt-build.cwl`.
  - See the updated `README.md` for more information on how to run the application.

#### Wflow

- Fixed the CWL workflow for the Wflow application package.
  - This can now be found in `/experimental/wflow/cwl/wflow-exp-run.cwl`.
    - **Note**: This is a temporary naming scheme until final acceptance.
  - See the updated `README.md` for more information on how to run the application.

- Updated the Dockerfile and rebuilt the image
  - Restructured the image by including a `/app` working directory.
  - Adjusted all the environmental paths to reflect the new directory structure (e.g. Julia is now `/app/env` etc.). I think this provides a cleaner and more organized structure. Something to consider also for HydroMT.

#### General

- To make life easier, and to prepare us for testing remote exection I have built the images and pushed them to my personal DockerHub registry. This is to omit the need for credentials which complicate things even more.

  - HydroMT image: `docker pull potato55/hydromt:latest`
    - Available here: `https://hub.docker.com/repository/docker/potato55/hydromt`

  - Wflow image: `docker pull potato55/wflow:latest`
    - Available here: `https://hub.docker.com/repository/docker/potato55/wflow`

In the future these can be in the Eurac registry, however, we should consider the option to make it publically available. This will make it easier for us and others to test and use the applications.
