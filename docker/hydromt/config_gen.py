#!/usr/bin/env python
"""
Script to update the wflow.ini configuration file based on the
inputs from the CWL workflow. This script is called by the
update-config.cwl file in the CWL workflow.
TODO:
- Add support for more configuration options
- Add error handling for missing configuration options
- Sell the whole workflow to the highest bidder
Usage:
    python config_gen.py [--use-env] [--res RES] [--precip_fn PRECIP_FN]
                         [--starttime STARTTIME] [--endtime ENDTIME]

    or

    export RES=0.008999999999
    export PRECIP_FN=emo1_stac
    export STARTTIME=2001-01-01T00:00:00
    export ENDTIME=2001-03-31T00:00:00

    python config_gen.py --use-env
"""

import argparse
import configparser
import logging
import os

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler()],
)


def parse_env_vars(
    var_names: list[str], default_values: dict[str, str] | None = None
) -> dict[str, str]:
    """
    Parse environment variables and return a dictionary of their values.
    If an environment variable is not set, use the default value if provided,
    otherwise raise an error.

    :param var_names: List of environment variable names to parse.
    :param default_values: Dict mapping env var names to default values. Optional.
    :return: Dictionary of environment variable names and their values.
    """
    default_values = default_values or {
        "RES": "0.008999999999",
        "PRECIP_FN": "emo1_stac",
        "STARTTIME": "2001-01-01T00:00:00",
        "ENDTIME": "2001-03-31T00:00:00",
        "TEMP_PET_FN": "emo1_stac"
    }

    env_vars = {}
    for var in var_names:
        value = os.getenv(var)
        if value is None:
            if var in default_values:
                value = default_values[var]
                logger.warning(
                    f"Environment variable {var} not set. Using default value: {value}"
                )
            else:
                raise EnvironmentError(
                    f"Environment variable {var} not set and no default value provided."
                )
        env_vars[var] = value
        logger.info(f"Environment variable {var} set to: {value}")
    return env_vars


def setup_parser() -> argparse.ArgumentParser:
    """
    Setup the argument parser for the update_config script
    :return: argparse.ArgumentParser

    arguments:
    - res: float, model resolution
    - precip_fn: str, precipitation forcing file name
    """
    parser = argparse.ArgumentParser(description="Update hydromt config file")
    parser.add_argument(
        "--res", type=float, default=0.008999999999, help="Model resolution"
    )
    parser.add_argument(
        "--precip_fn",
        type=str,
        default="emo1_stac",
        help="Precipitation forcing file name",
    )
    parser.add_argument(
        "--starttime",
        type=str,
        default="2001-01-01T00:00:00",
        help="Start time for the simulation",
    )
    parser.add_argument(
        "--endtime",
        type=str,
        default="2001-03-31T00:00:00",
        help="End time for the simulation",
    )
    parser.add_argument(
        "--temp_pet_fn",
        type=str,
        default="emo1_stac",
        help="Temperature and potential evapotranspiration forcing file name",
    )
    logger.info("Parser setup complete.")
    return parser


def set_permissions():
    """
    Set permissions for the current working directory to 777
    Not sure if this is completely necessary but CWL tool
    is a pain in the ass about permissions
    """
    cwd = os.getcwd()
    os.chmod(cwd, 0o777)
    logger.info(f"Set permissions for {cwd} to 777")


def generate_config(config_dict: dict, output_path: str):
    config = configparser.ConfigParser()
    config.read_dict(config_dict)

    with open(output_path, "w") as configfile:
        config.write(configfile)

    logger.info(f"Contents of config file: {config_dict}")
    logger.info(f"Config file written to path: {output_path}")


def main():
    parser = setup_parser()
    parser.add_argument(
        "--use-env",
        action="store_true",
        help="Use environment variables instead of command line arguments",
    )
    args = parser.parse_args()
    set_permissions()

    if args.use_env:
        logger.info("Reading configuration from environment variables...")
        env_values = parse_env_vars(["RES", "PRECIP_FN", "STARTTIME", "ENDTIME"])
        res = float(env_values["RES"])
        precip_fn = env_values["PRECIP_FN"]
        starttime = env_values["STARTTIME"]
        endtime = env_values["ENDTIME"]
    else:
        logger.info("Reading configuration from command line arguments...")
        res = args.res
        precip_fn = args.precip_fn
        starttime = args.starttime
        endtime = args.endtime

    config_dict = {
        "setup_config": {
            "starttime": starttime,
            "endtime": endtime,
            "timestepsec": 86400,
            "input.path_forcing": "forcings.nc",
        },
        "setup_basemaps": {
            "hydrography_fn": "merit_hydro_stac",
            "basin_index_fn": "merit_hydro_index",
            "upscale_method": "ihu",
            "res": res,
        },
        "setup_rivers": {
            "hydrography_fn": "merit_hydro_stac",
            "river_geom_fn": "rivers_lin2019",
            "river_upa": 30,
            "rivdph_method": "powlaw",
            "min_rivdph": 1,
            "min_rivwth": 30,
            "slope_len": 2000,
            "smooth_len": 5000,
        },
        "setup_lakes": {
            "lakes_fn": "hydrolakes_v10",
            "min_area": 2.0,
        },
        "setup_reservoirs": {
            "reservoirs_fn": "grand_v1.3",
            "timeseries_fn": "gww",
            "min_area": 0.5,
        },
        "setup_glaciers": {
            "glaciers_fn": "rgi60_global",
            "min_area": 1.0,
        },
        "setup_gauges": {
            "gauges_fn": "ado_gauges",
            "index_col": "id",
            "snap_to_river": "True",
            "derive_subcatch": "False",
        },
        "setup_lulcmaps": {
            "lulc_fn": "corine_2012",
            "lulc_mapping_fn": "corine_mapping",
        },
        "setup_laimaps": {
            "lai_fn": "modis_lai_v061",
        },
        "setup_soilmaps": {
            "soil_fn": "soilgrids_2020_stac",
            "ptf_ksatver": "brakensiek",
        },
        "setup_precip_forcing": {
            "precip_fn": precip_fn,
            "precip_clim_fn": "None",
            "chunksize": 1,
        },
        "setup_temp_pet_forcing": {
            "temp_pet_fn": "cerra_stac",
            "kin_fn": "cerra_land_stac",
            "press_correction": "True",
            "temp_correction": "True",
            "wind_correction": "False",
            "dem_forcing_fn": "cerra_orography",
            "pet_method": "makkink",
            "skip_pet": "False",
            "chunksize": 1,
        },
        "setup_constant_pars": {
            "KsatHorFrac": 100,
            "Cfmax": 3.75653,
            "cf_soil": 0.038,
            "EoverR": 0.11,
            "InfiltCapPath": 5,
            "InfiltCapSoil": 600,
            "MaxLeakage": 0,
            "rootdistpar": -500,
            "TT": 0,
            "TTI": 2,
            "TTM": 0,
            "WHC": 0.1,
            "G_Cfmax": 5.3,
            "G_SIfrac": 0.002,
            "G_TT": 1.3,
        },
    }

    output_path = "wflow.ini"
    if not os.path.exists("output"):
        os.makedirs("output")

    generate_config(config_dict, output_path=output_path)
    logger.info("CONFIG UPDATE STEP COMPLETE. WOOHOO!")


if __name__ == "__main__":
    main()
