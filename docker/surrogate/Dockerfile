#FROM ghcr.io/intertwin-eu/itwinai:jlab-slim-latest
#FROM ghcr.io/intertwin-eu/itwinai:0.2.2-torch2.1
#FROM ghcr.io/intertwin-eu/itwinai:torch-slim-latest
FROM ghcr.io/intertwin-eu/hython-itwinai-plugin:v0.4

LABEL version="1.0"
LABEL description="Itwinai based Docker image for training surrogate models"
LABEL maintainer="Juraj Zvolensky, Iacopo Ferrario"
LABEL organization="Eurac Research"

ENV HYDRA_FULL_ERROR=1

# !! Workaraound for overriding the default image plugin which does not have latest developments
RUN git clone -b iacopo https://github.com/interTwin-eu/hython-itwinai-plugin.git
RUN cd /app/hython-itwinai-plugin && pip install .
RUN cd .

COPY requirements.txt ./requirements.txt

# Breaks if not using --use-pep517 (https://github.com/pypa/pip/issues/6334)
RUN pip install --upgrade pip && pip install --no-cache-dir --use-pep517 -r requirements.txt

# !! Remove when fixing image plugin
RUN git clone -b main https://github.com/interTwin-eu/hython.git
RUN cd /app/hython && pip install .
RUN cd .

RUN mkdir -p ./use-case
RUN mkdir -p ./model
RUN mkdir -p /data

COPY src/decode_keys.py ./use-case
COPY src/gen_surr_config.py ./use-case
COPY src/training_local.yaml ./use-case
COPY src/training_vega.yaml ./use-case
