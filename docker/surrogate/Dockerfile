#FROM ghcr.io/intertwin-eu/itwinai:jlab-slim-latest
#FROM ghcr.io/intertwin-eu/itwinai:0.2.2-torch2.1
FROM ghcr.io/intertwin-eu/itwinai:torch-slim-latest

ENV HYDRA_FULL_ERROR=1

COPY requirements.txt ./requirements.txt

# Breaks if not using --use-pep517 (https://github.com/pypa/pip/issues/6334) 
RUN pip install --upgrade pip && pip install --no-cache-dir --use-pep517 -r requirements.txt 

RUN mkdir -p ./use-case
RUN mkdir -p /data

COPY src/training_local.yaml ./use-case
COPY src/training_vega.yaml ./use-case




