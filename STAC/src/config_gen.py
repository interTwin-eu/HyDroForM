#!/usr/bin/env python
"""
Script to update the wflow.ini configuration file based on the
inputs from the CWL workflow. This script is called by the
update-config.cwl file in the CWL workflow.
TODO:
- Add support for more configuration options
- Add support for more complex configuration updates
- Add error handling for missing configuration options
- Sell the whole workflow to the highest bidder
"""

import os
import argparse
import configparser
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler()],
)


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
        "res", type=float, default=0.008999999999, help="Model resolution"
    )
    parser.add_argument(
        "precip_fn",
        type=str,
        default="cerra_land_stac",
        help="Precipitation forcing file name",
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


# def update_config(args) -> None:
#     """
#     Updates the wflow.ini configuration file based on the
#     CWL inputs. Currently supports:
#     - resolution
#     - precipitation forcings
#     """
#     config_updates = {
#         "[setup_basemaps]": {"res": args.res},
#         "[setup_precip_forcing]": {"precip_fn": args.precip_fn},
#     }

#     logger.info(f"Updating config file with the following values: {config_updates}")

#     config_file = "/hydromt/output/wflow.ini"
#     with open(config_file, "r") as f:
#         config = f.readlines()

#     current_section = None
#     for i, line in enumerate(config):
#         if "[" in line and "]" in line:
#             current_section = line.strip()
#         if current_section and current_section in config_updates:
#             for key, value in config_updates[current_section].items():
#                 if key in line:
#                     config[i] = f"{key} = {value}\n"

#     with open(config_file, "w") as f:
#         f.writelines(config)


def generate_config(config_dict: dict):
    config = configparser.ConfigParser()
    config.read_dict(config_dict)

    with open("wflow.ini", "w") as configfile:
        config.write(configfile)

    logger.info(f"Contents of config file: {config_dict}")
    logger.info(f"Config file written to path: {os.getcwd()}/{configfile.name})]")


def main():
    parser = setup_parser()
    args = parser.parse_args()
    set_permissions()
    config_dict = {
        "setup_config": {
            "starttime": "2001-01-01T00:00:00",
            "endtime": "2001-03-31T00:00:00",
            "timestepsec": 86400,
            "input.path_forcing": "forcings.nc",
        },
        "setup_basemaps": {
            "hydrography_fn": "merit_hydro",
            "basin_index_fn": "merit_hydro_index",
            "upscale_method": "ihu",
            "res": args.res or 0.008999999999,  # 0.008333 -> 30 arcsec ~ 1 km
        },
        "setup_rivers": {
            "hydrography_fn": "merit_hydro",
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
            "soil_fn": "soilgrids_2020",
            "ptf_ksatver": "brakensiek",
        },
        "setup_precip_forcing": {
            "precip_fn": args.precip_fn or "cerra_land_stac",
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
    generate_config(config_dict)
    logger.info("CONFIG UPDATE STEP COMPLETE. WOOHOO!")

if __name__ == "__main__":
    main()
