from prefect import flow, task
from prefect.task_runners import SequentialTaskRunner
# from prefect.tasks import ShellTask
from prefect_shell import shell_run_command

from dotenv import load_dotenv
from pathlib import Path

load_dotenv()


KAGGLE_DATASET_OWNER = "michaelarman"
KAGGLE_DATASET_NAME = "poemsdataset"
OUTPUT_PATH = "../data/poems"


@task
def unzip_dataset():
    directory_to_extract_to = f'{OUTPUT_PATH}/'
    path_to_zip_file = f"{OUTPUT_PATH}/{KAGGLE_DATASET_NAME}.zip"
    with zipfile.ZipFile(path_to_zip_file, 'r') as zip_ref:
        zip_ref.extractall(directory_to_extract_to)
    return True

@task
def save_to_cloud():
    # TODO: Upload dataset-files to AWS s3 buckect
    pass

@flow(name="datalake_flow", description="", task_runner=SequentialTaskRunner)
def datalake_flow():
    shell_run_command(command=f"kaggle datasets download {KAGGLE_DATASET_OWNER}/{KAGGLE_DATASET_NAME} --path {OUTPUT_PATH}", return_all=True)
    unzip_dataset()

datalake_flow()