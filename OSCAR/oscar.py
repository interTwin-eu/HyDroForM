import argparse
import json
import os
import sys
import subprocess
from minio import Minio
from oscar_python.client import Client
import oscar_python._utils as utils
import tarfile
import uuid
import requests
import openeo
import subprocess

def parse_arguments():
    # parser = argparse.ArgumentParser()

    # parser.add_argument("--endpoint", required=True, help="The endpoint URL to OSCAR.")
    # parser.add_argument("--token", help="The authentication EGI token.")
    # parser.add_argument("--service", required=True, help="The service name.")
    # parser.add_argument("--service_config", required=True, help="The path to the service definition fdl.")
    # parser.add_argument("--output", required=True, help="The output directory.")
    # parser.add_argument("--user", help="The username for basic auth.")
    # parser.add_argument("--password", help="The password for basic auth.")

    # if len(sys.argv) == 1:
    #     parser.print_help(sys.stderr)
    #     sys.exit(1)

    # args = parser.parse_args()
    # variables = vars(args)

    # endpoint = variables['endpoint']
    # user = variables.get('user')
    # password = variables.get('password')
    # token = variables.get('token')
    # service = variables['service']
    # service_config = variables['service_config']  # os.path.abspath(
    # output = variables['output']

    conn = openeo.connect("https://openeo.intertwin.fedcloud.eu/1.1.0").authenticate_oidc()

    TOKEN = "/home/jzvolensky/.local/share/openeo-python-client/refresh-tokens.json"
    with open(TOKEN) as f:
        token_data = json.load(f)
        refresh_token = token_data["https://aai.egi.eu/auth/realms/egi"]["openeo-platform-default-client"]["refresh_token"].strip()
    print(refresh_token)

    token = get_access_token(refresh_token)

    endpoint = "https://oscar-grnet.intertwin.fedcloud.eu"
    user = ""
    password = ""
    token = f'{token}'
    service = "hydroform"
    service_config = "oscar_services/hydroform_oscar_svc.yaml"
    output = "output"

    if user and password:
        token = None
    elif token:
        user = None
        password = None

    return endpoint, user, password, token, service, service_config, output


def get_access_token(refresh_token):
    url = "https://aai.egi.eu/auth/realms/egi/protocol/openid-connect/token"
    data = f"grant_type=refresh_token&refresh_token={refresh_token}&client_id=openeo-platform-default-client&scope=openid%20email%20offline_access%20eduperson_scoped_affiliation%20eduperson_entitlement"
    result = subprocess.run(
    ["curl", "-X", "POST", url, "-d", data],
    stdout=subprocess.PIPE,
    text=True
    )
    if result.returncode == 0:
        token_info = json.loads(result.stdout)
        print(json.dumps(token_info, indent=4))
    else:
        print(f"Failed to get access token: {result.returncode}")

    return token_info["access_token"]
    
def check_oscar_connection():
    # Check the service or create it
    print("Checking OSCAR connection status")
    if user and password:
        options_basic_auth = {'cluster_id': 'cluster-id',
                              'endpoint': endpoint,
                              'user': user,
                              'password': password,
                              'ssl': 'True'}
        print("Using credentials user/password")
    elif token:
        options_basic_auth = {'cluster_id': 'cluster-id',
                              'endpoint': endpoint,
                              'oidc_token': token,
                              'ssl': 'True'}
        print("Using credentials token")
    else:
        print("Introduce the credentials user/password or token")
        exit(2)

    client = Client(options=options_basic_auth)
    try:
        client.get_cluster_info()
    except Exception as err:
        print(err)
        print("OSCAR cluster not Found")
        exit(1)
    return client


def check_service(client, service, service_config):
    print("Checking OSCAR service status")
    try:
        service_info = client.get_service(service)
        service_data = json.loads(service_info.text)
        minio_info = service_data["storage_providers"]["minio"]["default"]
        input_info = service_data["input"][0]
        output_info = service_data["output"][0]
        if service_info.status_code == 200:
            print("OSCAR Service " + service + " already exists")
            return minio_info, input_info, output_info
    except Exception:
        print("OSCAR Service " + service + " not found. Creating it...")
        try:
            creation = client.create_service(service_config)
            print(creation)
        except Exception as err:
            print(err)
            print("OSCAR Service " + service + " not created")
            exit(1)
    try:
        service_info = client.get_service(service)
        minio_info = json.loads(service_info.text)["storage_providers"]["minio"]["default"]
        input_info = json.loads(service_info.text)["input"][0]
        output_info = json.loads(service_info.text)["output"][0]
        print("OSCAR Service " + service + " created")
        return minio_info, input_info, output_info
    except Exception as err:
        print(err)
        print("OSCAR Service " + service + " not created")
        exit(1)


def connect_minio(minio_info):
    # Create client with access and secret key.
    print("Creating connection with MinIO")
    client = Minio(minio_info["endpoint"].split("//")[1],
                   minio_info["access_key"],
                   minio_info["secret_key"])
    return client


def upload_file_minio(client, input_info, input_file):
    # Upload the file into input bucket
    print("Uploading the file into input bucket")
    random = uuid.uuid4().hex + "_" + input_file.split("/")[-1]
    client.fput_object(
        input_info["path"].split("/")[0],
        '/'.join(input_info["path"].split("/")[1:]) + "/" + random,
        input_file,
    )
    return random.split("_")[0]


def wait_output_and_download(client, output_info, output):
    # Wait the output
    print("Waiting the output")
    with client.listen_bucket_notification(
        output_info["path"].split("/")[0],
        prefix='/'.join(output_info["path"].split("/")[1:]),
        events=["s3:ObjectCreated:*", "s3:ObjectRemoved:*"],
    ) as events:
        for event in events:
            outputfile = event["Records"][0]["s3"]["object"]["key"]
            print(event["Records"][0]["s3"]["object"]["key"])
            break
    # Download the file
    print("Downloading the file")
    client.fget_object(output_info["path"].split("/")[0], 
                       outputfile,
                       output + "/" + outputfile.split("/")[-1])
    return output + "/" + outputfile.split("/")[-1]


def compress(filename):
    print("Compressing input")
    files = os.listdir(filename)
    tar_file_ = tarfile.open(filename + ".tar", "w")
    for x in files:
        tar_file_.add(name=filename + "/" + x, arcname=x)
    tar_file_.close()
    return filename + ".tar"


def extract(output_file):
    print("Decompressing output")
    with tarfile.open(output_file, 'r') as tar:
        for member in tar.getmembers():
            tar.extract(member, path=output)


def run_service(client, service, token, output):
    print(f'Running {service} service')
    response = None
    try:
        data = {
            "Records": [
                {
                    "requestParameters": {
                        "principalId": "uid",
                        "sourceIPAddress": "ip"
                    },
                }
            ]
        }
        json_data = json.dumps(data).encode('utf-8')
        if token:
            headers = utils.get_headers_with_token(token)
            response = requests.request("post", endpoint + "/job/" + service, headers=headers, verify=client.ssl, data=json_data, timeout=1500)
        elif user and password:
            response = requests.request("post", endpoint + "/job/" + service, auth=(user, password), verify=client.ssl, data=json_data, timeout=1500)
        else:
            raise ValueError("Either token or user/password must be provided")
    except Exception as err:
        print("Failed with: ", err)
    return response


# Example usage
if __name__ == "__main__":
    endpoint, user, password, token, service, service_config, output = parse_arguments()
    client = check_oscar_connection()
    minio_info, input_info, output_info = check_service(client, service, service_config)
    print(minio_info, input_info, output_info)
    response = run_service(client, service, token, output)
    output_file = wait_output_and_download(connect_minio(minio_info), output_info, output)
    extract(output_file)
