#!/usr/bin/env python
import os
import uuid
import argparse
import logging
import requests
import json    
from raster2stac import Raster2STAC

logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO,
    handlers=[logging.StreamHandler()]
)

logging.getLogger().setLevel(logging.DEBUG)
numba_logger = logging.getLogger('numba')
numba_logger.setLevel(logging.WARNING)

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

parser = argparse.ArgumentParser()
parser.add_argument('--staticmaps_path', help='Static maps from HydroMT')
parser.add_argument('--forcings_path', help='Forcings from HydroMT')
parser.add_argument('--output_dir', help='Output folder for the STAC files')


def main(*args) -> None:

    try:
        args = parser.parse_args()
    except Exception as e:
        logger.error(f"Error parsing arguments: {e}")
        return
    
    logger.info(f"Arguments: {args}")
    
    staticmaps_path = args.staticmaps_path
    
    forcings_path = args.forcings_path

    output_dir = args.output_dir

    os.makedirs(output_dir, exist_ok=True)

    logger.info(f"staticmaps_path: {staticmaps_path}")
    logger.info(f"forcings_path: {forcings_path}")

    r2s = Raster2STAC(
        data = [[f"{staticmaps_path}"],[f"{forcings_path}"]], 
        collection_id = f"{uuid.uuid4()}_WFLOW_FORCINGS_STATICMAPS", 
        collection_url = "https://stac.openeo.eurac.edu/api/v1/pgstac/collections", # collection_ur, the STAC API where we foresee to share this Collection
        output_folder= output_dir, #TODO: check if ok to write in this local new directory
        description="Collection containing the forcings.nc and staticmaps.nc files generated by HydroMT, necessary to run WFLOW.",
        title="HydroMT result files",
        ignore_warns=False,
        keywords=['intertwin', 'climate'],
        links= [{
            "rel": "license",
            "href": "https://cds.climate.copernicus.eu/api/v2/terms/static/licence-to-use-copernicus-products.pdf",
            "title": "License to use Copernicus Products"
        }],
        providers=[
            {
                "url": "https://cds.climate.copernicus.eu/cdsapp#!/dataset/10.24381/cds.622a565a",
                "name": "Copernicus",
                "roles": [
                    "producer"
                ]
            },
            {
                "url": "https://cds.climate.copernicus.eu/cdsapp#!/dataset/10.24381/cds.622a565a",
                "name": "Copernicus",
                "roles": [
                    "licensor"
                ]
            },
            {
                "url": "http://www.eurac.edu",
                "name": "Eurac Research - Institute for Earth Observation",
                "roles": [
                    "host"
                ]
            }
        ],
        stac_version="1.0.0",
        s3_upload=False,
        bucket_file_prefix = "INTERTWIN/",
        bucket_name = "eurac-eo",
        aws_access_key = "", #TODO: don't publish this in the repo
        aws_secret_key = "",
        aws_region = "s3-eu-west-1",
        version=None,
        license="proprietary",
        write_collection_assets=True
    )

    r2s.generate_netcdf_stac()

    STAC_API_URL = "https://stac.openeo.eurac.edu/api/v1/pgstac/collections"

    with open(f"{output_dir}/{r2s.collection_id}.json","r") as f:
        stac_collection_to_post = json.load(f)
        requests.post(r2s.collection_url,json=stac_collection_to_post)
        stac_items = []
        with open(f"{output_dir}/inline_items.csv","r") as f:
            stac_items = f.readlines()
            for it in stac_items:
                stac_data_to_post = json.loads(it)
                requests.post(f"{STAC_API_URL}/{r2s.collection_id}/items",json=stac_data_to_post)

if __name__ == '__main__':
    main()

