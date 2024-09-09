FROM ghcr.io/intertwin-eu/itwinai:0.2.2-torch2.1

RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt 

RUN mkdir -p /use-case

COPY src/config.yaml /use-case




