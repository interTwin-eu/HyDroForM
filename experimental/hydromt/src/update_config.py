#!/usr/bin/env python3

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
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    handlers=[logging.StreamHandler()])


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


def update_config(args) -> None:
    """
    Updates the wflow.ini configuration file based on the
    CWL inputs. Currently supports:
    - resolution
    - precipitation forcings
    """
    config_updates = {
        "[setup_basemaps]": {"res": args.res},
        "[setup_precip_forcing]": {"precip_fn": args.precip_fn},
    }

    logger.info(f"Updating config file with the following values: {config_updates}")

    config_file = "/hydromt/output/wflow.ini"
    with open(config_file, "r") as f:
        config = f.readlines()

    current_section = None
    for i, line in enumerate(config):
        if "[" in line and "]" in line:
            current_section = line.strip()
        if current_section and current_section in config_updates:
            for key, value in config_updates[current_section].items():
                if key in line:
                    config[i] = f"{key} = {value}\n"

    with open(config_file, "w") as f:
        f.writelines(config)


def main():
    parser = setup_parser()
    args = parser.parse_args()
    set_permissions()
    update_config(args)
    logger.info("CONFIG UPDATE STEP COMPLETE. WOOHOO!")


if __name__ == "__main__":
    main()
