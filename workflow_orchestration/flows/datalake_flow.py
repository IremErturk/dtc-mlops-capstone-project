import os
import zipfile

# from constants import (
#     KAGGLE_DATASET_NAME,
#     KAGGLE_DATASET_OWNER,
#     RAW_DATA_LOCAL_PATH,
#     RAW_DATA_S3_PATH,
# )
from dotenv import load_dotenv
from prefect import flow, task
from prefect.task_runners import SequentialTaskRunner
from prefect_shell import shell_run_command

from minio import Minio
from minio.error import S3Error

load_dotenv()

KAGGLE_DATASET_OWNER = "michaelarman"
KAGGLE_DATASET_NAME = "poemsdataset"

RAW_DATA_PATH = "raw_data/poems"

LOCAL_ROOT_PATH = ".."
LOCAL_ARTIFACT_PATH = "artifacts"
RAW_DATA_LOCAL_PATH = f"{LOCAL_ROOT_PATH}/{LOCAL_ARTIFACT_PATH}/{RAW_DATA_PATH}"

S3_ARTIFACT_BUCKET_NAME = "mlops-zoomcamp-capstone-artifacts" # TODO: should be working for mlops-zoomcamp-capstone-artifacts
S3_PREFECT_PATH = "prefect-artifacts" 
RAW_DATA_S3_PATH = f"{S3_ARTIFACT_BUCKET_NAME}/{S3_PREFECT_PATH}/{RAW_DATA_PATH}"

@flow(name="download_dataset_sub_flow", description="Download Kaggle dataset")
def download_kaggle_dataset(dataset_owner: str, dataset_name: str, output_path: str):
    shell_run_command(
        command=f"kaggle datasets download {dataset_owner}/{dataset_name} --path {output_path}",
        return_all=True,
    )


@task
def unzip_dataset(output_path: str):
    directory_to_extract_to = f"{output_path}/"
    path_to_zip_file = f"{output_path}/{KAGGLE_DATASET_NAME}.zip"
    try:
        with zipfile.ZipFile(path_to_zip_file, "r") as zip_ref:
            zip_ref.extractall(directory_to_extract_to)
    except Exception as err: # TODO: Not stop whole extraction process, but extractall fails in some
        errname = type(err).__name__
        errnum = err.errno
        if (errname == 'OSError') and (errnum == 36):
            print(err)
            print("Unzip failed to extract all existing poems folders/files")
    return True

@flow(name="upload_minio_sub_flow", description="Upload raw data to minio bucket")
def upload_folder_to_minio(folder_path: str, bucket_object: str):
    
    minio_root_user = os.getenv("MINIO_ROOT_USER")
    minio_root_password = os.getenv("MINIO_ROOT_PASSWORD")
    minio_endpoint = os.getenv("MINIO_ENDPOINT") # TODO: fix hardcoded localhost:9000 in docker-compose or env variables
    
    minio_client = Minio( 
        minio_endpoint,
        access_key=minio_root_user,
        secret_key=minio_root_password,
        secure=False # fix of Caused by SSLError(SSLError(1, '[SSL: WRONG_VERSION_NUMBER]
    )
    
    found = minio_client.bucket_exists(S3_ARTIFACT_BUCKET_NAME)
    if not found:
        minio_client.make_bucket(S3_ARTIFACT_BUCKET_NAME)
    else:
        print(f"Bucket {S3_ARTIFACT_BUCKET_NAME} already exists")

    # No mirror function in minio-sdk as it follows s3-sdk
    # Therefore maybe it is better to follow same approach here too
    try:
        minio_client.fput_object(S3_ARTIFACT_BUCKET_NAME, bucket_object, f"{folder_path}/poemsdataset.zip")
    except S3Error as err:
        print("Failed to put files to Minio Bucket", err)

    # # TODO: mc should be installed in the container
    # shell_run_command(
    #     command=f"mc mirror --overwrite {folder_path} {S3_ARTIFACT_BUCKET_NAME}",
    #     return_all=True,
    # )


@flow(name="upload_s3_sub_flow", description="Upload raw data to s3 bucket")
def upload_folder_to_s3(folder_path: str, bucket_path: str):
    shell_run_command(
        command=f"aws s3 sync {folder_path} s3://{bucket_path}",
        return_all=True,
    )


@flow(name="datalake_flow", description="", task_runner=SequentialTaskRunner)
def datalake_flow():
    """
    Datalake flow ensures that poemsdataset is being retrieved from Kaggle
    and stored in an accessible storage (local filesystem, aws bucket) for the next flow definitions.
    """
    download_kaggle_dataset(
        dataset_name=KAGGLE_DATASET_NAME,
        dataset_owner=KAGGLE_DATASET_OWNER,
        output_path=RAW_DATA_LOCAL_PATH,
    )
    # unzip_dataset(output_path=RAW_DATA_LOCAL_PATH)
    upload_folder_to_minio(folder_path=f"{RAW_DATA_LOCAL_PATH}", bucket_object=f"{S3_PREFECT_PATH}/{RAW_DATA_PATH}/poemsdataset.zip")
    # TODO: should decide how it should act on production and local
    # if os.getenv("environment") != "local":
    #   upload_folder_to_minio(folder_path=RAW_DATA_LOCAL_PATH, bucket_object={S3_PREFECT_PATH}/{RAW_DATA_PATH})
    #   upload_folder_to_s3(folder_path=RAW_DATA_LOCAL_PATH, bucket_path=RAW_DATA_S3_PATH)
    

if __name__ == "__main__":
    datalake_flow()
