FROM python:3.10-bullseye

WORKDIR /hydromt

RUN apt-get update && \
    apt-get -y install python3-pip && \
    rm -rf /var/lib/apt/lists/*


COPY requirements.txt wflow.ini /hydromt/
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install git+https://github.com/iacopoff/hydromt.git@cwl#egg=hydromt && \
    pip install git+https://github.com/clausmichele/openeo-pg-parser-networkx.git@pydantic2#egg=openeo_pg_parser_networkx


RUN mkdir -p /hydromt/output /hydromt/data
COPY data_catalog.yaml /hydromt/

COPY ./src/config_gen.py /hydromt

COPY ./src/build.sh /usr/bin/build
COPY ./src/config_gen.py /usr/bin/config_gen.py
RUN chmod +x /usr/bin/build /usr/bin/config_gen.py /hydromt/config_gen.py