#!/usr/bin/env python
import pystac
import os
import sys
from datetime import datetime

def create_catalog(input_dir, output_dir):

    os.makedirs(output_dir, exist_ok=True)

    catalog = pystac.Catalog(id='my-catalog', description='My Catalog')

    for root, dirs, files in os.walk(input_dir):
        for file in files:
            item = pystac.Item(id=file,
                               geometry=None,
                               bbox=None,
                               datetime=datetime.now(),
                               properties={})

            asset = pystac.Asset(href=os.path.join(root, file),
                                 media_type=pystac.MediaType.JSON)

            item.add_asset(key='data', asset=asset)
            catalog.add_item(item)

    catalog.normalize_and_save(root_href=output_dir,
                               catalog_type=pystac.CatalogType.SELF_CONTAINED)

if __name__ == '__main__':
    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    create_catalog(input_dir, output_dir)