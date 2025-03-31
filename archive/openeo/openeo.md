# HyDroForM on OpenEO

This directory contains verified and working CWL workflows to be used in OpenEO

The contents for each process are the required CWL components and examples required to run the CWL workflow with `cwltool`.

The source code can be found in the repository.

## Current workflows

List of currently available workflows

### HydroMT

run with `cwltool`:

```zsh
cd hydromt
```

```zsh
cwltool --verbose --no-read-only --outdir ./hydromt-output hydromt-build-demo.cwl#hydromt-workflow params.json > output.log 2>&1
```

**Note**: Remove `> output.log 2>&1` to see the output in the terminal. \
**Note**: Feel free to modify the flags except `--no-read-only`

### Wflow

The input of `Wflow` is generate by HydroMT. As it is right now you need to change the `params-wflow.yaml` file to match the output of `HydroMT`.

It is setup in this repository to show how the output of `HydroMT` can be used as input for `Wflow`.

run with `cwltool`:

```zsh
cd wflow
```

```zsh
cwltool --verbose --no-read-only --outdir ./wflow-output --no-match-user wflow-demo.cwl#wflow-workflow params-wflow.yaml
```

### Surrogate (WIP)

```zsh
cd surrogate
```

```zsh
cwltool --verbose --tmpdir $PWD --no-match-user --no-read-only --outdir ./surrogate-output  surrogate_demo.cwl#surrogate-demo surrogate_params.json
```

*NOTE*: Currently the Surrogate output is a bit all over the place, as it generates some stuff in the `./openeo` as well. I dont really know why, we can probably discard this in the future as we will upload online.
