# Running HydroMT workflows with OSCAR

The container is available on Docker Hub:

```bash
iacopoff/hydromt-test
```

By default it starts in the `/hydromt` directory. Everything happens here so there is no need to `cd` anywhere.

We use several steps and scripts to run the HydroMT part of our workflow.

First we need to generate a config file for HydroMT based on user input. This is done using the `config_gen.py` script.

Currently we only expose two parameters for testing. This step can be run using the following command:

**All paths are predefined so you do not need to touch or change anything.**

**All scripts and required files (such as data_catalog.yaml) are available in the container as well, I don't know if you can call those directly in OSCAR or not.**

```bash
python /usr/bin/config_gen.py 0.008999999999 cerra_land_stac
```

Where:

- `0.008999999999` is the model resolution
- `cerra_land_stac` is a dataset name (we have multiple options)

In the future we will expose more parameters but for testing this is enough.

This will generate a `wflow.ini` configuration file used in `HydroMT`.

Now we can run the HydroMT workflow like this:

```bash
hydromt build wflow model -r "{'subbasin': [11.4750, 46.8720]}" -d data_catalog.yaml -i wflow.ini -vvv
```

*Note*: If you need to run an external script to call this in OSCAR, I included a `build.sh` script that can be used to run the above command. You can call this script from OSCAR.

```bash
./build.sh
```

Where:

- `-r` is the region of interest
- `-d` is the catalog file, which contains links to the STAC data
- `-i` is the config file we just generated

HydroMT generates a `model` directory containing some output files which we need for the next steps. For OpenEO integration we need this wrapped as STAC collections. This is done using the `/usr/bin/stac.py` script in the container.

```bash
python /usr/bin/stac.py --staticmaps_path "./model/staticmaps.nc" --forcings_path "./model/forcings.nc" --output_dir "./model/stac"
```

Where:

- `--staticmaps_path` is the path to the staticmaps file
- `--forcings_path` is the path to the forcings file
- `--output_dir` is the directory where the STAC collections will be saved

It uses the `Raster2Stac` component to wrap the results and also push to and S3 bucket. I have disabled this so we do not hav to shuffle credentials around. What it will do is generate the output locally.

The output files will looks something like this:

```bash
20010101000000_20010331000000/
20200101000000_20201201000000/
cbc5681b-11e0-4343-bdf2-07351176e81e_WFLOW_FORCINGS_STATICMAPS.json
inline_items.csv
items/
```

That is all. These files can then be used in our later steps.

## Experiment: Running HydroMT workflows with OSCAR (interTwin cluster)

### Interactively through the OSCAR GUI

This experiment is to test the feasibility of running HydroMT workflows with OSCAR on the interTwin cluster.

OSCAR cluster: https://beautiful-lederberg3.im.grycap.net/

To access the OSCAR cluster you need to have an EGI account and join the interTwin VO: https://aai.egi.eu/registry/co_petitions/start/coef:622

#### Step 1: Create the OSCAR Service for HydroMT

First we need to create a new OSCAR service for HydroMT. This can be done through the OSCAR web interface in Services -> Deploy with FDL. The following files are required:
* hydroform_oscar_svc.yaml (FDL file that defines the OSCAR Service)
* script.sh (Shell script that will be executed inside the container)

![Deploy with FDL](hydromt_oscar_img/hydroform_create_svc.png)


#### Step 2: Invoke the OSCAR Service

After the OSCAR service is created, we can invoke it through the OSCAR web interface in Services -> More Options for hydroform Service -> Invoke -> Run.

![Invoke OSCAR Service](hydromt_oscar_img/hydroform_invoke.png)

![Run OSCAR Service](hydromt_oscar_img/hydroform_run.png)

#### Step 3: Monitor the OSCAR Service

We can monitor the OSCAR service through the OSCAR web interface in Services -> More Options for hydroform Service -> Logs.

![Monitor OSCAR Service](hydromt_oscar_img/hydroform_logs.png)

#### Step 4: Retrieve the OSCAR Service Output

After the OSCAR service is completed, we can retrieve the output from MinIO through the OSCAR web interface in Minio Storage -> hydroform.

**Note**: The output files are stored in the MinIO bucket for testing purposes.

![Retrieve OSCAR Service Output](hydromt_oscar_img/hydroform_minio.png)

### Programatically through an oscar-python script

Command:

```
python oscar.py \
  --endpoint=https://beautiful-lederberg3.im.grycap.net \
  --token= \
  --service=hydroform \
  --service_config=oscar_services/hydroform_oscar_svc.yaml \
  --output=output
```

You need to add your EGI token, you can get it from [https://aai.egi.eu/token/](https://aai.egi.eu/token/).

Remember, you need to be in the [interTwin VO](https://aai.egi.eu/registry/co_petitions/start/coef:622).
