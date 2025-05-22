"""Script to read STAC collections, download them, and merge them into NetCDF
as well as downloading the config file from the links section of the collection
and saving it to the local directory.

The script also checks for the presence of the 'wflow_sbm_toml' link in the STAC collection
and downloads the config file if it exists.

sample usage:

python read_stac.py https://example.com/stac/collection.json /path/to/output
"""
import os
import requests
import pystac
import s3fs
import logging
import xarray as xr
import boto3
import botocore.auth
import botocore.awsrequest


logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)


def validate_stac_availability(collection_url: str) -> bool:
    try:
        response = requests.get(collection_url)
        response.raise_for_status()
        return True
    except requests.RequestException as e:
        logger.error(f"Error accessing STAC URL {collection_url}: {e}")
        return False

def list_items(collection_url: str) -> list:
    try:
        catalog = pystac.read_file(collection_url)
        items = catalog.get_all_items()
        return items
    except Exception as e:
        logger.error(f"Error listing items from STAC collection {collection_url}: {e}")
        return []

def download_collection(collection_url: str, output_dir: str) -> None:
    """
    Download all assets from the STAC items in the collection.

    Args:
        collection_url (str): The STAC collection URL.
        output_dir (str): The directory to save the downloaded assets.

    Returns:
        None
    """
    try:
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        items_url = f"{collection_url}/items"
        response = requests.get(items_url)
        response.raise_for_status()
        items = response.json().get("features", [])

        if not items:
            logger.info(f"No items found in the STAC collection at {items_url}.")
            return

        for item in items:
            item_id = item["id"]
            assets = item.get("assets", {})
            if not assets:
                logger.info(f"No assets found for item {item_id}. Skipping.")
                continue

            for asset_key, asset in assets.items():
                asset_url = asset["href"]
                logger.info(f"Downloading asset '{asset_key}' from {asset_url}")

                asset_filename = f"{asset_key}.nc"
                asset_path = os.path.join(output_dir, asset_filename)

                if asset_url.startswith("s3://"):
                    fs = s3fs.S3FileSystem(
                        anon=False,
                        key="9DPH3I91JYRSY106ZCB0", #os.getenv("AWS_ACCESS_KEY_ID"),
                        secret="XIadtArgCzkNlhVjrEkEtHNhrA3Pt1cjtAtdV23K", #os.getenv("AWS_SECRET_ACCESS_KEY"),
                        client_kwargs={'endpoint_url': 'https://objectstore.eodc.eu:2222'}
                    )
                    if fs.exists(asset_url):
                        with fs.open(asset_url, "rb") as fsrc, open(asset_path, "wb") as fdst:
                            fdst.write(fsrc.read())
                        logger.info(f"Downloaded asset '{asset_key}' to {asset_path}")
                    else:
                        logger.error(f"Asset {asset_url} does not exist in S3.")
                else:
                    response = requests.get(asset_url)
                    response.raise_for_status()
                    with open(asset_path, "wb") as f:
                        f.write(response.content)
                    logger.info(f"Downloaded asset '{asset_key}' to {asset_path}")

        logger.info(f"Downloaded all assets to {output_dir}")
    except Exception as e:
        logger.error(f"Error downloading STAC collection from {collection_url}: {e}")

def download_config_file(collection_url: str, output_dir: str) -> None:
    """
    Download the config file from the STAC collection if the 'wflow_sbm_toml' link is present.

    Args:
        collection_url (str): The STAC collection URL.
        output_dir (str): The directory to save the downloaded config file.

    Returns:
        None
    """
    try:
        catalog = pystac.read_file(collection_url)
        links = catalog.links

        for link in links:
            if link.rel == "wflow_sbm_toml": 
                config_url = link.href
                fs = s3fs.S3FileSystem(
                    anon=False,
                    key="9DPH3I91JYRSY106ZCB0",   #os.getenv("AWS_ACCESS_KEY"),
                    secret="XIadtArgCzkNlhVjrEkEtHNhrA3Pt1cjtAtdV23K",    #os.getenv("AWS_SECRET_KEY"),
                    client_kwargs={'endpoint_url': 'https://objectstore.eodc.eu:2222'}
                )
                if fs.exists(config_url):
                    with fs.open(config_url, "rb") as f:
                        config_content = f.read()
                    config_file_path = os.path.join(output_dir, "wflow_sbm.toml")
                    with open(config_file_path, "wb") as f:
                        f.write(config_content)
                    logger.info(f"Downloaded config file to {config_file_path}")
                else:
                    logger.error(f"Config file {config_url} does not exist in S3.")
    
    except Exception as e:
        logger.error(f"Error downloading config file from STAC collection {collection_url}: {e}")

def main(collection_urls: list, output_dir: str) -> None:
    for collection_url in collection_urls:
        logger.info(f"Processing STAC collection: {collection_url}")
        
        if not validate_stac_availability(collection_url):
            logger.error(f"STAC collection {collection_url} is not available. Skipping...")
            continue
        else:
            logger.info(f"STAC collection {collection_url} is available.")

        items = list_items(collection_url)
        if not items:
            logger.error(f"No items found in STAC collection {collection_url}. Skipping...")
            continue
        
        logger.info("Downloading assets from STAC collection...")
        download_collection(collection_url, output_dir)
        download_config_file(collection_url, output_dir)
        
        logger.info(f"Finished processing STAC collection: {collection_url}")

    logger.info("All operations completed successfully.")

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Download STAC collections and config files.")
    parser.add_argument("collection_urls", type=str, nargs="+", help="List of STAC collection URLs.")
    parser.add_argument("output_dir", type=str, help="Directory to save downloaded files.")
    
    args = parser.parse_args()
    
    main(args.collection_urls, args.output_dir)