
import boto3

datasets = [
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/wflow_forcings/cerra_forcings.nc",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/cerra_land/orography/CERRAL_orography.nc",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/wflow_forcings/eobsv27_forcings.nc",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/wflow_forcings/eobsv28_forcings.nc",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/eobsv27/elev_ens_0.1deg_reg_v27.0e.nc",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/wflow_basins/merit_hydro_index.gpkg",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/MCD12A3H.v061/modis_lai.nc",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/corine/2012/clc12_4326.tif",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/ecodatacube/4326/lcv_landcover.hcl_lucas.corine.rf_p_30m_0..0cm_2018_eumap_epsg4326_v0.1.tif",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/corine/corine_mapping.csv",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/rivers_ge30m/rivers_ge30m_4326.gpkg",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/hydrolakes/HydroLAKES_polys_v10.gpkg",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/rgi60_global/rgi.gpkg",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/grand/v1.3/GRanD_Version_1_3/GRanD_reservoirs_v1_3.gpkg",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/ADO/ADO_discharge_metadata.csv",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/ADO/ADO_Adige_surrogate_test_discharge_metadata.csv",
"/mnt/CEPH_PROJECTS/InterTwin/hydrologic_data/wflow_hydrography/elevtn.tif"
]

aws_access_id = ""
aws_secret_key = ""
bucket = ""
prefix = ""

s3 = boto3.client(
    's3',
    aws_access_key_id=aws_access_id,
    aws_secret_access_key=aws_secret_key,
)

for dataset in datasets:
    try:
        path_parts = dataset.split('/')
        hydrologic_data_index = path_parts.index('hydrologic_data')
        relative_path_parts = path_parts[hydrologic_data_index + 1:]
        relative_path = '/'.join(relative_path_parts)
        
        object_name = f"{prefix}{relative_path}"
        
        s3.upload_file(dataset, bucket, object_name)
        print(f"Successfully uploaded {object_name}")
    except Exception as e:
        print(f"Failed to upload {object_name}. Error: {e}")

response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)

object_urls = []

try:
    with open("object_urls.txt", "w") as f:
        for obj in response['Contents']:
            object_key = obj['Key']
            object_url = f"https://{bucket}.s3.amazonaws.com/{object_key}"
            object_urls.append(object_url)
            print(object_url)
            f.write(f"{object_url}\n")
except:
    print("Failed to list objects")

