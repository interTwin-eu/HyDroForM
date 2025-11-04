FROM python:3.10-bullseye AS build

LABEL version="1.0"
LABEL description="Hydromt Docker image for building and updating hydromt models"
LABEL maintainer="Juraj Zvolensky, Iacopo Ferrario"
LABEL organization="Eurac Research"

WORKDIR /hydromt

##################### Python setup #####################

RUN apt-get update && apt-get install -y \
    vim \
    && pip install --upgrade pip setuptools wheel

COPY requirements.txt /hydromt/

# # Install GDAL Python bindings matching system GDAL version
# RUN pip install GDAL==$(gdal-config --version)
# Install requirements (GDAL already removed from requirements.txt)

RUN pip install -r /hydromt/requirements.txt
#COPY all_basins.geojson /hydromt/
# RUN git clone -b feature/stac_zarr_storage https://github.com/interTwin-eu/openeo-processes-dask.git
# RUN cd openeo-processes-dask/openeo_processes_dask/specs && \
#     git clone https://github.com/eodcgmbh/openeo-processes.git -b 2024.7.0
# RUN cd .
# RUN cd openeo-processes-dask && pip install .
# RUN cd .
# RUN pip uninstall -y pydantic && pip install pydantic==2.8.2 openeo_pg_parser_networkx==2024.10.0
# clone commit https://gitlab.inf.unibz.it/earth_observation_public/raster-to-stac/-/commit/0df2519c93698314becedf230255b8ce6b5c29a9

RUN git clone https://gitlab.inf.unibz.it/earth_observation_public/raster-to-stac.git
RUN cd raster-to-stac && git checkout 0df2519c93698314becedf230255b8ce6b5c29a9 

ENV R2S_VERSION=0.9.0

RUN cd raster-to-stac && sed -i "s/SEMANTIC_VERSION/$R2S_VERSION/g" pyproject.toml

# Install raster-to-stac from the local directory (with fixed version)
RUN pip install ./raster-to-stac

# INSTALL openeo-processes-dask and submodule
RUN git clone -b feature/load_stac_odc https://github.com/interTwin-eu/openeo-processes-dask.git
RUN cd openeo-processes-dask/openeo_processes_dask/specs && \ 
    git clone https://github.com/eodcgmbh/openeo-processes.git -b 2024.7.0
RUN cd .
RUN cd openeo-processes-dask && pip install . 
RUN cd .

# RUN pip install pystac==1.14.0

##################### HydroMT Components setup #####################

RUN mkdir -p /hydromt/output /hydromt/data

RUN chmod -R 777 /hydromt

COPY data_catalog.yaml /hydromt/data_catalog.yaml

COPY stac.py /hydromt/stac.py
COPY config_gen.py /hydromt/config_gen.py
COPY convert_lowercase.py /hydromt/convert_lowercase.py
COPY decode_keys.sh /hydromt/decode_keys.sh
COPY build.sh /hydromt/build.sh
##################### Set executables #####################

RUN chmod +x  /hydromt/stac.py \
              /hydromt/config_gen.py \
              /hydromt/build.sh \
              /hydromt/convert_lowercase.py \
              /hydromt/decode_keys.sh

FROM python:3.10-bullseye

WORKDIR /hydromt

COPY --from=build /hydromt /hydromt
COPY --from=build /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/bin/vim /usr/bin/vim
COPY --from=build /usr/share/vim /usr/share/vim
