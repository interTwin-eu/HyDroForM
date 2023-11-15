
## Instruction


### HydroMT

TBD


### Wflow 

`cd wflow`

Build Wflow app image

`./build.sh`


Run Wflow model in container 


`docker run -v /mnt/CEPH_PROJECTS/InterTwin/Wflow/Wflow_ERA5_Adige_Catchment/Adige_clipped/:/data -it intertwin:wflow-latest --output bla.nc --forcing forcings.nc`
