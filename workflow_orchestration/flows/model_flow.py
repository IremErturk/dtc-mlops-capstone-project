import os
from typing import List

import boto3
from constants import (
    MODEL_NAME,
    MODELS_LOCAL_PATH,
    MODELS_S3_PATH,
    RAW_DATA_LOCAL_PATH,
    RAW_DATA_PATH,
    S3_ARTIFACT_BUCKET_NAME,
    S3_PREFECT_PATH,
)
from dotenv import load_dotenv
from fastai.text.all import (
    Callback,
    CrossEntropyLossFlat,
    Learner,
    LMDataLoader,
    Perplexity,
    TfmdLists,
    TitledStr,
    Transform,
    get_text_files,
    tensor,
    torch,
)
from prefect import flow, task
from prefect.task_runners import SequentialTaskRunner
from prefect_shell import shell_run_command
from transformers import GPT2LMHeadModel, GPT2TokenizerFast

load_dotenv()


class TransformersTokenizer(Transform):
    def __init__(self, tokenizer):
        self.tokenizer = tokenizer

    def encodes(self, x):
        tokens = self.tokenizer.tokenize(x)
        return tensor(self.tokenizer.convert_tokens_to_ids(tokens))

    def decodes(self, x):
        return TitledStr(self.tokenizer.decode(x.cpu().numpy()))


class DropOutput(Callback):
    def after_pred(self):
        self.learn.pred = self.pred[0]


@task
def init_artifacts():
    pretrained_weights = "gpt2"
    tokenizer = GPT2TokenizerFast.from_pretrained(pretrained_weights)
    model = GPT2LMHeadModel.from_pretrained(pretrained_weights)
    return tokenizer, model


@task
def read_data_local(path: str, folders: List[str]) -> List[str]:
    file_paths = get_text_files(path, folders)
    data = [
        file.open().read() for file in file_paths
    ]  # to make things easy we will gather all texts in one numpy array
    print(f"Data size: {len(data)}")
    return data


@task
def prepare_models_folder():
    models_root_folder = MODELS_LOCAL_PATH
    if not os.path.exists(models_root_folder):
        os.makedirs(models_root_folder)
    pass


@task
def read_data_s3(bucket_name: str, bucket_path: str, prefixes: List[str]) -> List[str]:
    s3 = boto3.client("s3")
    data = []
    for prefix in prefixes:
        kwargs = {"Bucket": bucket_name, "Prefix": f"{bucket_path}/{prefix}"}
        contents = []
        while True:
            resp = s3.list_objects_v2(**kwargs)
            for obj in resp["Contents"]:
                d = s3.get_object(Bucket=bucket_name, Key=obj["Key"])
                content = d["Body"].read()
                contents.append(content.decode("utf-8"))
            try:
                kwargs["ContinuationToken"] = resp["NextContinuationToken"]
            except KeyError:
                data.extend(contents)
                break
    print(f"Data size : {len(data)}")
    return data


@task
def prepare_data(tokenizer, data):
    batch_size, sequence_lenght = 4, 256
    splits = [
        range(int(70 * len(data) / 100)),
        range(int(70 * len(data) / 100), len(data)),
    ]  # use a 70/30 split for training and validation
    tls = TfmdLists(data, TransformersTokenizer(tokenizer), splits=splits, dl_type=LMDataLoader)
    dls = tls.dataloaders(bs=batch_size, seq_len=sequence_lenght, device=torch.device("cpu"))
    return dls


@task
def fine_tune_and_save(dataloaders, model, model_path):
    learn = Learner(
        dataloaders, model, loss_func=CrossEntropyLossFlat(), cbs=[DropOutput], metrics=Perplexity()
    ).to_fp16()
    # learn.validate()
    # learn.fit_one_cycle(1, 1e-4)
    # learn.export(model_path) # TODO: expects that models folder is created
    torch.save(learn.model, model_path)
    print(f"Model for poem-generator is created at {model_path}")
    return model_path


@flow(name="upload_s3_sub_flow", description="Upload model to s3 bucket")
def upload_folder_to_s3(model_path: str, bucket_path: str):
    shell_run_command(
        command=f"aws s3 sync {model_path} s3://{bucket_path}",
        return_all=True,
    )


@flow(name="model_flow", description="Register the Model for ", task_runner=SequentialTaskRunner)
def model_flow():
    gpt2_tokenizer, gpt2_model = init_artifacts()
    if os.getenv("environment") == "local":
        ballads_data = read_data_local(path=RAW_DATA_LOCAL_PATH, folders=["forms/ballad/"])
    else:
        ballads_data = read_data_s3(
            bucket_name=S3_ARTIFACT_BUCKET_NAME,
            bucket_path=f"{S3_PREFECT_PATH}/{RAW_DATA_PATH}",
            prefixes=["forms/ballad/"],
        )

    dls = prepare_data(tokenizer=gpt2_tokenizer, data=ballads_data)
    model_path = fine_tune_and_save(
        model=gpt2_model, model_path=f"{MODELS_LOCAL_PATH}/{MODEL_NAME}", dataloaders=dls
    )

    if os.getenv("environment") != "local":
        prepare_models_folder()
        upload_folder_to_s3(model_path=MODELS_LOCAL_PATH, bucket_path=MODELS_S3_PATH)


model_flow()

# poetry run prefect deployment build flows/model_flow.py:model_flow --name cicd --work-queue prefect-agent --storage-block s3/deployments --output model_flow.yaml
