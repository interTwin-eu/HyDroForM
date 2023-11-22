FROM  julia:1.9.3-bookworm

RUN apt update

RUN mkdir /env 

COPY Project.toml /env
COPY Manifest.toml /env

RUN julia -e 'using Pkg;Pkg.activate("/env");Pkg.instantiate()'

RUN mkdir /data
RUN mkdir /src

# WORKDIR /src

COPY ./src/run.jl /src
COPY ./src/wflow_sbm.toml /src
COPY ./src/run_wflow.sh /usr/bin/run_wflow

RUN chmod +x /usr/bin/run_wflow

#ENTRYPOINT ["julia", "--project=/env", "-t 4", "run.jl"]


