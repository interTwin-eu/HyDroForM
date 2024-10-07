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
cwltool --verbose --no-read-only --force-docker-pull --outdir ./hydromt-output hydromt-build-workflow.cwl#hydromt-workflow params.json > output.log 2>&1
```

**Note**: Remove `> output.log 2>&1` to see the output in the terminal. \
**Note**: Feel free to modify the flags except `--no-read-only`
