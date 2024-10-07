import boto3
import os

aws_access_id = ""
aws_secret_key = ""
bucket = "eurac-eo"
prefix = "INTERTWIN/HYDROFORM/soilgrids_2020/"

s3 = boto3.client(
    's3',
    aws_access_key_id=aws_access_id,
    aws_secret_access_key=aws_secret_key,
)

local_directory = "/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/soilgrid_2020"

for root, dirs, files in os.walk(local_directory):
    for filename in files:

        if filename.endswith(".tif"):

            file_path = os.path.join(root, filename)

            relative_path = os.path.relpath(file_path, local_directory)
            s3_key = os.path.join(prefix, relative_path)

            s3.upload_file(file_path, bucket, s3_key)
            print(f"Uploaded {file_path} to s3://{bucket}/{s3_key}")