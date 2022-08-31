from typing import List

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
from transformers import GPT2LMHeadModel, GPT2TokenizerFast

load_dotenv()


INPUT_DATA_PATH = "../data/poems"
OUTPUT_MODEL_PATH = "../data/models/gtp2-learn.pkl"


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
def read_data(path: str, folders: List[str]) -> List[str]:
    file_paths = get_text_files(path, folders)
    data = [
        file.open().read() for file in file_paths
    ]  # to make things easy we will gather all texts in one numpy array
    print(f"Data size: {len(data)}")
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
def fine_tune_and_save(dataloaders, model):
    learn = Learner(
        dataloaders, model, loss_func=CrossEntropyLossFlat(), cbs=[DropOutput], metrics=Perplexity()
    ).to_fp16()
    # learn.validate()
    # learn.fit_one_cycle(1, 1e-4)
    learn.export(OUTPUT_MODEL_PATH)
    return OUTPUT_MODEL_PATH


@flow(name="model_flow", description="Register the Model for ", task_runner=SequentialTaskRunner)
def model_flow():
    gpt2_tokenizer, gpt2_model = init_artifacts()
    # poems_data = read_data(path=DATA_PATH, folders = ['forms','topics'])
    ballads_data = read_data(path=INPUT_DATA_PATH, folders=["ballad"])
    dls = prepare_data(tokenizer=gpt2_tokenizer, data=ballads_data)
    model_path = fine_tune_and_save(model=gpt2_model, dataloaders=dls)
    print(f"Model for poetry-generator is created at {model_path}")


model_flow()
