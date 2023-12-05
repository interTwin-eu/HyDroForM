
## Instruction


### HydroMT


`cd wflow`

Build Hydromt app image

`./build.sh`


Build Wflow model

`docker run -v /mnt/CEPH_PROJECTS/InterTwin/Wflow/data:/data -it --rm intertwin:hydromt`


### Wflow 

`cd wflow`

Build Wflow app image

`./build.sh`


Run Wflow model in container 


`docker run -v /mnt/CEPH_PROJECTS/InterTwin/Wflow/Wflow_ERA5_Adige_Catchment/Adige_clipped/:/data -it intertwin:wflow-latest forcings.nc outptut.nc`


### Surrogate

TBD

### Parameter Learning

TBD
