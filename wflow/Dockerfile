FROM  julia:1.10.0-bookworm

RUN apt update
RUN apt install -y git

RUN git clone https://github.com/JuliaRegistries/General.git

RUN mkdir /env 

COPY Project.toml /env
COPY Manifest.toml /env

RUN julia -e 'using Pkg;Pkg.activate("/env");Pkg.instantiate()'

# directory where there are wflow input datasets produced by HydroMT
RUN mkdir /data

# configuration files for wflow
# RUN mkdir /output

COPY ./src/run.jl run.jl
COPY ./src/run_wflow.sh /usr/bin/run_wflow

RUN chmod +x /usr/bin/run_wflow
RUN chmod +x run.jl
