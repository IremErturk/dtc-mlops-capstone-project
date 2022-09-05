import zipfile

from dotenv import load_dotenv
from prefect import flow, task
from prefect.task_runners import SequentialTaskRunner
from prefect_shell import shell_run_command

from workflow_orchestration.constants import (
    KAGGLE_DATASET_NAME,
    KAGGLE_DATASET_OWNER,
    RAW_DATA_LOCAL_PATH,
    RAW_DATA_S3_PATH,
)

load_dotenv()


@task
def unzip_dataset(output_path: str = RAW_DATA_LOCAL_PATH):
    directory_to_extract_to = f"{output_path}/"
    path_to_zip_file = f"{output_path}/{KAGGLE_DATASET_NAME}.zip"
    with zipfile.ZipFile(path_to_zip_file, "r") as zip_ref:
        zip_ref.extractall(directory_to_extract_to)
    return True


@task
def upload_folder_to_s3(
    folder_path: str = RAW_DATA_LOCAL_PATH, bucket_path: str = RAW_DATA_S3_PATH
):
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
    shell_run_command(
        command=f"kaggle datasets download {KAGGLE_DATASET_OWNER}/{KAGGLE_DATASET_NAME} --path {RAW_DATA_LOCAL_PATH}",
        return_all=True,
    )
    unzip_dataset(output_path=RAW_DATA_LOCAL_PATH)
    upload_folder_to_s3(folder_path=RAW_DATA_LOCAL_PATH, bucket_path=RAW_DATA_S3_PATH)


datalake_flow()
