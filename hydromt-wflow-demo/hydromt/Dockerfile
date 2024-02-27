
FROM ghcr.io/osgeo/gdal:ubuntu-small-3.8.1

RUN apt update
RUN apt -y install python3-pip

# python packages
COPY requirements.txt ./

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# configuration files for hydromt 
RUN mkdir /output

COPY wflow.ini ./output
COPY data_catalog.yaml ./output

# directory where there are datasets referred by datacatalog.yaml
RUN mkdir /data 

COPY ./src/build.sh /usr/bin/build
RUN chmod +x /usr/bin/build

