FROM python:3.10-bullseye

WORKDIR /hydromt

RUN apt-get update && \
    apt-get -y install vim && \
    apt-get -y install python3-pip && \
    rm -rf /var/lib/apt/lists/*


COPY requirements.txt wflow.ini /hydromt/

RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt 

# INSTALL openeo-processes-dask and submodule
RUN git clone -b feature/load_stac_odc https://github.com/interTwin-eu/openeo-processes-dask.git
RUN cd openeo-processes-dask/openeo_processes_dask/specs && \ 
    git clone https://github.com/eodcgmbh/openeo-processes.git -b 2024.7.0
RUN cd .
RUN cd openeo-processes-dask && pip install . 
RUN cd .

RUN mkdir -p /hydromt/output /hydromt/data

# COMMENT THESE TWO LINES BELOW
#COPY data_catalog.yaml /hydromt/
#RUN mkdir /data

# COPY ./config_gen.py /hydromt

COPY ./build.sh /usr/bin/build
COPY ./update.sh /usr/bin/update

COPY ./config_gen.py /usr/bin/config_gen.py
COPY ./stac.py /usr/bin/stac.py

RUN chmod +x /usr/bin/build /usr/bin/config_gen.py /usr/bin/update /usr/bin/stac.py
# /hydromt/config_gen.py
