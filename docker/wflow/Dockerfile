FROM  julia:1.10.1-bookworm

LABEL version="1.0"
LABEL description="Wflow Docker image for running hydrological workflows"
LABEL maintainer="Juraj Zvolensky, Iacopo Ferrario"
LABEL organization="Eurac Research"

USER root

RUN apt update && apt install -y python3 python3-pip git

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

COPY requirements.txt /app/requirements.txt
#Test this
RUN pip3 install --break-system-packages -r /app/requirements.txt
#Otherwise use this
#RUN python3 -m venv /app/venv
#RUN /app/venv/bin/pip install --upgrade pip
#RUN /app/venv/bin/pip install -r /app/requirements.txt
#ENV PATH="/app/venv/bin:$PATH"

COPY ./src/stac.py /app/src/stac.py
COPY ./src/to_zarr.py /app/src/to_zarr.py
COPY ./src/read_stac.py /app/src/read_stac.py
COPY ./src/decode_keys.py /app/src/decode_keys.py

RUN chmod +x /app/src/stac.py /app/src/to_zarr.py /app/src/read_stac.py /app/src/decode_keys.py


