FROM  julia:1.9.3-bookworm

RUN apt update

RUN mkdir /env 

COPY Project.toml /env
COPY Manifest.toml /env

RUN julia -e 'using Pkg;Pkg.activate("/env");Pkg.instantiate()'

# directory where there are wflow input datasets produced by HydroMT
RUN mkdir /data

# configuration files for wflow
RUN mkdir /output

COPY ./src/run.jl /usr/bin/run.jl
COPY ./src/run.jl /output/run.jl
COPY ./src/run_wflow.sh /usr/bin/run_wflow

RUN chmod +x /usr/bin/run.jl
RUN chmod +x /usr/bin/run_wflow