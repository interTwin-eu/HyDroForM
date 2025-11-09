FROM python:3.10-bullseye

LABEL version="0.1"
LABEL description="Docker image for hydromt build step"
LABEL maintainer="Juraj Zvolensky"
LABEL maintainer.email="juraj.zvolensky@eurac.edu"

WORKDIR /hydromt/

RUN apt-get update && \
    apt-get -y install vim && \
    apt-get -y install python3-pip && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt data_catalog.yaml /hydromt/

RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# TODO: Do we really need this? it is quite ugly
RUN git clone -b feature/load_stac_odc https://github.com/interTwin-eu/openeo-processes-dask.git
RUN cd openeo-processes-dask/openeo_processes_dask/specs && \
    git clone https://github.com/eodcgmbh/openeo-processes.git -b 2024.7.0
RUN cd .
RUN cd openeo-processes-dask && pip install .
RUN cd .

RUN pip uninstall -y pydantic && pip install pydantic==2.8.2 openeo_pg_parser_networkx==2024.10.0
