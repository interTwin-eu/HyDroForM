
FROM ghcr.io/osgeo/gdal:ubuntu-small-3.8.1

WORKDIR /hydromt

RUN apt update
RUN apt -y install python3-pip

COPY requirements.txt /hydromt

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir -p /hydromt/output /hydromt/data

COPY wflow.ini data_catalog.yaml ./src/update_config.py /hydromt/output/

COPY ./src/build.sh /usr/bin/build
RUN chmod +x /usr/bin/build

