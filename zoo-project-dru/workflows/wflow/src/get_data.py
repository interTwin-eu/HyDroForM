from typing import List
import sys
import os
import requests
import pystac
import logging
from requests.adapters import HTTPAdapter

"""
Script to be used inside the Wflow docker container to download data from a STAC endpoint.
Currently accepts a single STAC URL or a list of STAC URLs as arguments.
We also support different STAC types (Catalog, Collection, Feature) and download the assets accordingly.

"""

"""
Script to be used inside the Wflow docker container to download data from a STAC endpoint.
Currently accepts a single STAC URL or a list of STAC URLs as arguments.
We also support different STAC types (Catalog, Collection, Feature) and download the assets accordingly.

"""

LOG_LEVEL = logging.INFO

if len(sys.argv) > 1 and sys.argv[1].upper() in [
    "DEBUG",
    "INFO",
    "WARNING",
    "ERROR",
    "CRITICAL",
]:
    LOG_LEVEL = getattr(logging, sys.argv[1].upper())
    sys.argv.pop(1)  # Remove the logging level argument from sys.argv

logging.basicConfig(
    level=LOG_LEVEL,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

# TODO: Need to test this against the ADES with its weird docker path setup

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DOWNLOAD_DIR = os.path.join(SCRIPT_DIR, "data")

# Set up an HTTP session to get a more robust connection handling since this is automated
# and we may have to deal with network issues.
adapter = HTTPAdapter(max_retries=3)
http = requests.Session()
http.mount("https://", adapter)
http.mount("http://", adapter)


def get_current_dir() -> str:
    """
    Get the current directory of the script.

    :return: Current directory of the script.
    """
    return os.path.dirname(os.path.abspath(__file__))


def download_asset(asset_url: str, download_dir: str) -> None:
    """
    Download an asset from a URL to a directory.

    :param asset_url: URL of the asset to download.
    :param download_dir: Directory to download the asset to

    :return: None
    """
    logging.debug(f"Starting download of asset: {asset_url}")
    try:
        response = http.get(asset_url, stream=True)
        response.raise_for_status()
        filename = os.path.join(download_dir, os.path.basename(asset_url))
        with open(filename, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        logging.info(f"Downloaded {filename}")
    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to download {asset_url}: {e}")
    except IOError as e:
        logging.error(f"Failed to write to {filename}: {e}")


def download_stac_items(items: List[pystac.Item], download_dir: str) -> None:
    """
    Download assets from a list of STAC items.

    :param items: List of STAC items to download assets from.
    :param download_dir: Directory to download the assets to.

    :return: None
    """
    logging.debug(f"Downloading {len(items)} STAC items")
    for item in items:
        for asset_key, asset in item.assets.items():
            logging.debug(f"Downloading asset {asset_key} from item {item.id}")
            download_asset(asset.href, download_dir)


def download_stac_collection(stac_url: str, download_dir: str) -> None:
    """
    Download assets from a STAC collection.
    We handle different STAC types (Catalog, Collection, Feature) and download the assets accordingly.

    :param stac_url: URL of the STAC collection.
    :param download_dir: Directory to download the assets to.

    :return: None
    """
    logging.debug(f"Fetching STAC collection from {stac_url}")
    try:
        response = http.get(stac_url)
        response.raise_for_status()
        catalog_content = response.json()

        if catalog_content["type"] == "Catalog":
            logging.debug("Processing STAC Catalog")
            catalog = pystac.Catalog.from_dict(catalog_content)
            download_stac_items(list(catalog.get_all_items()), download_dir)
        elif catalog_content["type"] == "Collection":
            logging.debug("Processing STAC Collection")
            collection = pystac.Collection.from_dict(catalog_content)
            items_url = next(
                link.href for link in collection.links if link.rel == "items"
            )
            items_response = http.get(items_url)
            items_response.raise_for_status()
            items_content = items_response.json()
            items = [pystac.Item.from_dict(item) for item in items_content["features"]]
            download_stac_items(items, download_dir)
        elif catalog_content["type"] == "Feature":
            logging.debug("Processing STAC Feature")
            item = pystac.Item.from_dict(catalog_content)
            download_stac_items([item], download_dir)
        else:
            logging.error(f"Unsupported STAC type: {catalog_content['type']}")
    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to fetch STAC collection {stac_url}: {e}")
    except Exception as e:
        logging.error(f"Failed to process STAC collection {stac_url}: {e}")


def main():
    if len(sys.argv) < 2:
        logging.error(
            "Usage: python get_data.py [LOG_LEVEL] <STAC_URL> [<STAC_URL> ...]"
        )
        logging.error("Error: No STAC URL provided.")
        sys.exit(1)

    stac_urls = sys.argv[1:]

    try:
        if not os.path.exists(DOWNLOAD_DIR):
            os.makedirs(DOWNLOAD_DIR)
    except OSError as e:
        logging.error(f"Failed to create directory {DOWNLOAD_DIR}: {e}")
        sys.exit(1)

    for stac_url in stac_urls:
        logging.debug(get_current_dir())
        download_stac_collection(stac_url, DOWNLOAD_DIR)


if __name__ == "__main__":
    main()
