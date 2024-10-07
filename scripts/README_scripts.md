# Sample development scripts

This is a place for our scripts which are used during the development such as S3 data upload/download, etc.

All of these are generally hardocoded and we do not recommend to use them in production.

## Current scripts

- `upload_data.py`: Uploades a list of CEPH paths to our S3 bucket.
- `upload_modis.py`: First checks and deletes the existing files in the S3 bucket and then uploads the MODIS data to the S3 bucket.
- `upload_soilgrids.py`: Uploads the SoilGrids data to the S3 bucket.
- `upload_uparea.py`: First checks and deletes the existing files and uploads the UPArea data to the S3 bucket.

**NOTE**: Double check before commiting that you have removed the hardcoded **credentials**.
