FROM  julia:1.10.1-bookworm

RUN apt update

RUN mkdir /env 

COPY Project.toml /env
COPY Manifest.toml /env

RUN julia --project=/env -e 'using Pkg;Pkg.instantiate()'

# directory where there are wflow input datasets produced by HydroMT
RUN mkdir /data

ENV PATH="$PATH:/usr/local/julia/bin"

# configuration files for wflow
#RUN mkdir /output

COPY ./src/run_wflow_2.sh /usr/bin/run_wflow

RUN chmod +x /usr/bin/run_wflow

# This is just for testing. Just providing a config file to wflow.
# Running wflow in a docker container, without being called from cwl, works.
# Once we are able to run properly wflow and this is fixed, this line should be removed 
# COPY wflow_sbm.toml /

