# Official Changelog

## Purpose

Since we are working on 1 branch now and my commit messages are getting \
ridiculously long, I thought it would be a good idea to start a changelog.

## 01/11/2025 preparation for the review

### Changes

- Move old stuff to the archive
- Rework the README to reflect the current state of the project
- Update the environment.yaml to include all necessary packages for local development
- add `example/usecase.ipynb` with a simple OpenEO workflow to run the use case
- Add github action to build and push the docker images
- Add documentation for the new features and changes
- Updated labels of docker images in the Dockerfiles

### In progress

- Final fixes for the use case containers
- Final testing and preparation of the use case example
- Final review of the documentation
- SQAaaS integration after this update

## 10/07/2024 Reworking the project structure in preparation for OpenEO demo

### Fixes

- Fixed HydroMT CWL to run with `cwltool`
- Created a fixed directory for `inputs` which are now the main source of input files for our model

- inputs
  - README_inputs.md
  - inputs_hydromt
    - catalog.yaml
    - config_gen.py
    - wflow.ini

### Changes

- Created a `scripts` directory for all the scripts that are used to do various one time tasks

- scripts
  - README_scripts.md
  - upload_data.py
  - upload_modis.py
  - upload_soilgrids.py
  - upload_uparea.py

- Created a `zoo-project-dru` directory for future K8s CWL work

- zoo-project-dru
  - examples
    - ades
      - delete.py
      - hydromt-build-workflow.cwl
      - hydromt-output
      - object_urls.txt
      - params.yaml
    - notebooks
      - cwltool_hydromt.ipynb
      - cwltool_wflow.ipynb

- Created a `openeo` directory for all the OpenEO related work (e.g. CWL workflows)

- openeo
  - hydromt
    - hydromt-build-workflow.cwl
    - hydromt-output
      - qwwwi05c
    - output.log
    - params.json
    - params.yaml
  - openeo.md

- Removed some unnecessary files and directories or duplicates which were not needed

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
