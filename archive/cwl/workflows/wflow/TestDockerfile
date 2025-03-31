FROM  julia:1.10.1-bookworm

USER root

RUN apt update

WORKDIR /app

RUN mkdir /app/env 

COPY Project.toml /app/env
COPY Manifest.toml /app/env

# directory where there are wflow input datasets produced by HydroMT
RUN mkdir -p /app/data && chmod -R 777 /app/data
RUN mkdir -p /app/data/run_default && chmod -R 777 /app/data/run_default
RUN mkdir -p /app/env/repo

RUN mkdir -p /output/run_default/outstate && chmod -R 777 /output

ENV JULIA_DEPOT_PATH=/app/env/repo
ENV JULIA_PROJECT=/app/env

RUN chmod -R 777 /app/env/repo

RUN julia --project=/app/env -e 'using Pkg; Pkg.instantiate()'

COPY ./src/run_wflow.sh /usr/bin/run_wflow
COPY ./src/wflow.jl /usr/bin/wflow

RUN chmod +x /usr/bin/run_wflow
RUN chmod +x /usr/bin/wflow

