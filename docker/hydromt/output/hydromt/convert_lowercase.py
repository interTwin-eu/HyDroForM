#!/usr/bin/env python
"""
Simple script to read a TOML configuration file and convert all keys to lowercase,
except for specific keys that should remain unchanged.
Uses argv to pass the input location of the TOML file and overwrites it with the new file.

It is incredible that this sh** is even necessary, but it is what it is...

Usage:
    python convert_lowercase.py /path/to/config.toml
"""

import toml
import sys
import logging
import re
import os

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler()],
)

def set_permissions():
    """
    Set permissions for the current working directory to 777
    Not sure if this is completely necessary but CWL tool
    is a pain in the ass about permissions
    """
    cwd = os.getcwd()
    os.chmod(cwd, 0o777)
    logger.info(f"Set permissions for {cwd} to 777")

set_permissions()

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

# Regex pattern to match datetime strings just in case, dates can be wonky
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


logger.info(f"Reading configuration file: {sys.argv[1]}")
config = toml.load(sys.argv[1])

logger.info("Converting keys to lowercase")
config = to_lowercase(config)

set_permissions()

logger.info(f"Writing configuration file: {sys.argv[1]}")
with open(sys.argv[1], "w") as f:
    toml.dump(config, f)

logger.info("Done")
