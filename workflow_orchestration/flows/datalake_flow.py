import os
import zipfile

from constants import (
    KAGGLE_DATASET_NAME,
    KAGGLE_DATASET_OWNER,
    RAW_DATA_LOCAL_PATH,
    RAW_DATA_S3_PATH,
)
from dotenv import load_dotenv
from prefect import flow, task
from prefect.task_runners import SequentialTaskRunner
from prefect_shell import shell_run_command

load_dotenv()


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
    with zipfile.ZipFile(path_to_zip_file, "r") as zip_ref:
        zip_ref.extractall(directory_to_extract_to)
    return True


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
    unzip_dataset(output_path=RAW_DATA_LOCAL_PATH)
    if os.getenv("environment") != "local":
        upload_folder_to_s3(folder_path=RAW_DATA_LOCAL_PATH, bucket_path=RAW_DATA_S3_PATH)


datalake_flow()
