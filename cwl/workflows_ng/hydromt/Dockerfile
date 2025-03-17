FROM python:3.10-bullseye AS build

LABEL version="EC Demo Review"
LABEL description="Hydromt Docker image for building and updating hydromt models"
LABEL maintainer="Juraj Zvolensky"
LABEL organization="Eurac Research"

WORKDIR /hydromt

##################### Python setup #####################

RUN apt-get update && \
    apt-get -y install vim && \
    apt-get -y install python3-pip && \
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

#TODO: Pass this at runtime
#COPY data_catalog.yaml /hydromt/

RUN chmod -R 777 /hydromt

##################### 1. Config update scripts #####################

# Replaced by direct shell script in CWL
#COPY config_gen.py /hydromt/config-update/config_gen.py
#COPY update.sh /hydromt/config-update/update.sh

##################### 2. Build HydroMT script #####################

# Replace by direct shell script in CWL
#COPY build.sh /hydromt/hydromt-build/build.sh

##################### 3. Save to STAC scripts #####################

COPY stac.py /hydromt/to-stac/stac.py
COPY to_stac.sh /hydromt/to-stac/to_stac.sh

##################### Set executables #####################

RUN chmod +x  /hydromt/to-stac/to_stac.sh \
              /hydromt/to-stac/stac.py
             #/hydromt/config-update/update.sh \
             #/hydromt/config-update/config_gen.py \
             #/hydromt/hydromt-build/build.sh \


FROM python:3.10-bullseye

WORKDIR /hydromt

COPY --from=build /hydromt /hydromt
COPY --from=build /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=build /usr/local/bin /usr/local/bin


##################### TODO: These I need to deal with and probably remove #####################

# COPY ./build.sh /usr/bin/build
# COPY ./update.sh /usr/bin/update
#COPY ./fix_wflow_sbm.sh /usr/bin/fix_wflow_sbm
#RUN chmod +x /usr/bin/fix_wflow_sbm
#COPY ./convert_lowercase.py /usr/bin/convert_lowercase.py
#RUN chmod +x /usr/bin/convert_lowercase.py
