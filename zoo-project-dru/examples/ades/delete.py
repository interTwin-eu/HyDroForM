import boto3


AWS_ID = ""
AWS_SECRET = ""
BUCKET = "eurac-eo"  

s3 = boto3.client(
    's3',
    aws_access_key_id=AWS_ID,
    aws_secret_access_key=AWS_SECRET,
)

key = 'INTERTWIN/HYDROFORM/cerra_land/orography/CERRAL_orography.nc'

s3.delete_object(Bucket=BUCKET, Key=key)

print(f"Deleted {key} from {BUCKET}")