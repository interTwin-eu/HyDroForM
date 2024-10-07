import boto3
import os

aws_access_id = ""
aws_secret_key = ""
aws_region = "eu-west-1"
bucket = "eurac-eo"
prefix = "MERIT_HYDRO"

file_path = "/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/wflow_hydrography/uparea.tif"
hardcoded_datetime = "20240301000000"
new_file_name = f"uparea_{hardcoded_datetime}.tif"

s3 = boto3.client(
    's3',
    aws_access_key_id=aws_access_id,
    aws_secret_access_key=aws_secret_key,
    region_name=aws_region
)

def check_and_delete(bucket, prefix, new_file_name) -> None:
    s3_key = f"{prefix}/{new_file_name}"
    try:
        s3.head_object(Bucket=bucket, Key=s3_key)
        print(f"File s3://{bucket}/{s3_key} already exists, deleting it...")
        s3.delete_object(Bucket=bucket, Key=s3_key)
        print(f"Deleted s3://{bucket}/{s3_key}")
    except s3.exceptions.ClientError as e:
        if e.response['Error']['Code'] == '404':
            print(f"File s3://{bucket}/{s3_key} does not exist")
        else:
            raise

def upload_file(file_path, bucket, prefix, new_file_name) -> None:
    s3_key = f"{prefix}/{new_file_name}"

    s3.upload_file(file_path, bucket, s3_key)
    print(f"Uploaded {file_path} to s3://{bucket}/{s3_key}")

if __name__ == "__main__":
    check_and_delete(bucket, prefix, new_file_name)
    upload_file(file_path, bucket, prefix, new_file_name)