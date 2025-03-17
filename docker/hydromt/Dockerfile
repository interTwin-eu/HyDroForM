FROM python:3.10-bullseye AS build

LABEL version="EC Demo Review"
LABEL description="Hydromt Docker image for building and updating hydromt models"
LABEL maintainer="Juraj Zvolensky"
LABEL organization="Eurac Research"

WORKDIR /hydromt

##################### Python setup #####################

RUN apt-get update && \
    apt-get -y install vim && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /hydromt/

RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt 

RUN git clone -b feature/load_stac_odc https://github.com/interTwin-eu/openeo-processes-dask.git
RUN cd openeo-processes-dask/openeo_processes_dask/specs && \ 
    git clone https://github.com/eodcgmbh/openeo-processes.git -b 2024.7.0
RUN cd .
RUN cd openeo-processes-dask && pip install . 
RUN cd .

RUN pip uninstall -y pydantic && pip install pydantic==2.8.2 openeo_pg_parser_networkx==2024.10.0

RUN pip install raster2stac@git+https://gitlab.inf.unibz.it/earth_observation_public/raster-to-stac.git@feature/add_netcdf_collection_2#egg=raster-to-stac

##################### HydroMT Components setup #####################

RUN mkdir -p /hydromt/output /hydromt/data

RUN chmod -R 777 /hydromt

COPY data_catalog.yaml /hydromt/data_catalog.yaml

COPY stac.py /hydromt/stac.py
COPY config_gen.py /hydromt/config_gen.py
COPY convert_lowercase.py /hydromt/convert_lowercase.py
COPY build.sh /hydromt/build.sh
##################### Set executables #####################

RUN chmod +x  /hydromt/stac.py \
              /hydromt/config_gen.py \
              /hydromt/build.sh \
              /hydromt/convert_lowercase.py

FROM python:3.10-bullseye

WORKDIR /hydromt

COPY --from=build /hydromt /hydromt
COPY --from=build /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/bin/vim /usr/bin/vim
COPY --from=build /usr/share/vim /usr/share/vim

