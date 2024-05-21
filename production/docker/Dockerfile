FROM python:3.10-bullseye

WORKDIR /hydromt

# Combine apt-get update and install into one RUN command to reduce layers
# Also clean up in the same layer to reduce image size
RUN apt-get update && \
    apt-get -y install python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Combine pip install commands into one RUN command to reduce layers
COPY requirements.txt wflow.ini /hydromt/
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install git+https://github.com/iacopoff/hydromt.git@cwl#egg=hydromt && \
    pip install git+https://github.com/clausmichele/openeo-pg-parser-networkx.git@pydantic2#egg=openeo_pg_parser_networkx



# Combine mkdir and COPY commands into one RUN command to reduce layers
RUN mkdir -p /hydromt/output /hydromt/data
COPY data_catalog.yaml /hydromt/

COPY ./src/config_gen.py /hydromt

# Combine COPY and chmod commands into one RUN command to reduce layers
COPY ./src/build.sh /usr/bin/build
COPY ./src/config_gen.py /usr/bin/config_gen.py
RUN chmod +x /usr/bin/build /usr/bin/config_gen.py /hydromt/config_gen.py