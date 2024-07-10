FROM python:3.10-bullseye

WORKDIR /hydromt

RUN apt-get update && \
    apt-get -y install python3-pip && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt wflow.ini /hydromt/
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install git+https://github.com/interTwin-eu/hydromt.git@stac#egg=hydromt && \
    pip install git+https://github.com/Open-EO/openeo-pg-parser-networkx@main#egg=openeo_pg_parser_networkx && \
    pip install git+https://github.com/interTwin-eu/hydromt_wflow@stac#egg=hydromt_wflow

RUN mkdir -p /hydromt/output /hydromt/data
# COPY data_catalog.yaml /hydromt/

# COPY ./config_gen.py /hydromt

COPY ./build.sh /usr/bin/build
COPY ./update.sh /usr/bin/update

COPY ./config_gen.py /usr/bin/config_gen.py
COPY ./stac.py /usr/bin/stac.py

RUN chmod +x /usr/bin/build /usr/bin/config_gen.py /usr/bin/update /usr/bin/stac.py
# /hydromt/config_gen.py