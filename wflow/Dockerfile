FROM  julia:1.9.3-bookworm

RUN apt update

RUN mkdir /env 

COPY Project.toml /env
COPY Manifest.toml /env

RUN mkdir /data

WORKDIR /src

COPY ./src/run.jl /src
COPY ./src/wflow_sbm.toml /src

RUN julia -e 'using Pkg;Pkg.activate("/env");Pkg.instantiate()'

ENTRYPOINT ["julia", "--project=/env", "-t 4", "run.jl"]


