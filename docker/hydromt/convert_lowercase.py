#!/usr/bin/env python
"""
Simple script to read a TOML configuration file, convert all keys to lowercase,
and append specific values to the TOML file.

Usage:
    python convert_lowercase.py /path/to/config.toml
"""

import logging
import os
import re
import sys

import toml

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler()],
)


def set_permissions():
    """
    Set permissions for the current working directory to 777.
    """
    cwd = os.getcwd()
    os.chmod(cwd, 0o777)
    logger.info(f"Set permissions for {cwd} to 777")


# List of keys that should not be converted to lowercase
exceptions = [
    "starttime",
    "endtime",
    "time_units",
    "theta_s",
    "theta_r",
    "kv_0",
    "soilthickness",
    "waterfrac",
    "pathfrac",
    "rootingdepth",
    "soilminthickness",
    "soilthickness",
    "specific_leaf",
    "storage_wood",
    "kext",
    "slope",
    "n",
    "bankfull_depth",
    "leaf_area_index",
]

# Regex pattern to match datetime strings
datetime_pattern = re.compile(r"\d{4}-\d{2}-\d{2}t\d{2}:\d{2}:\d{2}", re.IGNORECASE)


def to_lowercase(data):
    """
    Recursively convert all keys to lowercase, except for the keys in the exceptions list.
    """
    if isinstance(data, dict):
        return {
            k.lower(): to_lowercase(v) if k.lower() not in exceptions else v
            for k, v in data.items()
        }
    elif isinstance(data, list):
        return [to_lowercase(item) for item in data]
    elif isinstance(data, str):
        if datetime_pattern.match(data):
            return data
        return data.lower()
    else:
        return data


def append_output_vertical(config):
    """
    Append [output.vertical] section with actevap and vwc to the TOML configuration.
    """
    logger.info("Appending [output.vertical] section to the configuration")
    if "output" not in config:
        config["output"] = {}
    if "vertical" not in config["output"]:
        config["output"]["vertical"] = {}

    config["output"]["vertical"]["actevap"] = "actevap"
    config["output"]["vertical"]["vwc"] = "vwc"

    logger.info("Appended values: [output.vertical] actevap='actevap', vwc='vwc'")
    return config


if __name__ == "__main__":
    if len(sys.argv) != 2:
        logger.error("Usage: python convert_lowercase.py /path/to/config.toml")
        sys.exit(1)

    input_file = sys.argv[1]
    logger.info(f"Reading configuration file: {input_file}")
    config = toml.load(input_file)

    logger.info("Converting keys to lowercase")
    config = to_lowercase(config)

    config = append_output_vertical(config)

    set_permissions()

    logger.info(f"Writing updated configuration file: {input_file}")
    with open(input_file, "w") as f:
        toml.dump(config, f)

    logger.info("Done")
