
FROM ghcr.io/osgeo/gdal:ubuntu-small-3.8.1

RUN apt update
RUN apt -y install python3-pip

COPY requirements.txt ./
COPY wflow.ini ./
COPY hydromt_data.yaml ./
COPY points.geojson ./

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir /data

RUN mkdir /model


CMD hydromt build wflow ./model -r "{'subbasin':'./points.geojson', 'strord':3}" -i wflow.ini -d hydromt_data.yaml -vvv 


