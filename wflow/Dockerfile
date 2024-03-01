FROM  julia:1.10.1-bookworm

RUN apt update

RUN mkdir /env 

COPY Project.toml /env
COPY Manifest.toml /env

# directory where there are wflow input datasets produced by HydroMT
RUN mkdir /data

RUN mkdir -p /env/repo

ENV JULIA_DEPOT_PATH=/env/repo
ENV JULIA_PROJECT=/env

RUN chmod -R 777 /env/repo

RUN julia --project=/env -e 'using Pkg;Pkg.instantiate()'

COPY ./src/run_wflow.sh /usr/bin/run_wflow
COPY ./src/wflow.jl /usr/bin/wflow

RUN chmod +x /usr/bin/run_wflow
RUN chmod +x /usr/bin/wflow

