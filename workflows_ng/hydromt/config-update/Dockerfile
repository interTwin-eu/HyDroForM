FROM python:3.10-bullseye

LABEL version="0.1"
LABEL description="Docker image for hydromt config-update step"
LABEL maintainer="Juraj Zvolensky"
LABEL maintainer.email="juraj.zvolensky@eurac.edu"

WORKDIR /hydromt

RUN apt-get update && \
    apt-get -y install vim && \
    apt-get -y install python3-pip && \
    rm -rf /var/lib/apt/lists/*

COPY config_gen.py /hydromt