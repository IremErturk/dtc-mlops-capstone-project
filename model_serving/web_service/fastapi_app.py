import os
from typing import Union
import logging

import boto3
from constants import (
    MODEL_NAME,
    MODELS_LOCAL_PATH,
    MODELS_PATH,
    S3_ARTIFACT_BUCKET_NAME,
    S3_PREFECT_PATH,
)
from dotenv import load_dotenv
import torch as trch
from fastapi import FastAPI
from pydantic import BaseModel
from transformers import GPT2TokenizerFast

load_dotenv()


class PoemFeatures(BaseModel):
    baseline: str
    form: Union[str, None] = None
    topic: Union[str, None] = None
    author: Union[str, None] = None


app = FastAPI()

# initialize some external resources, for faster responses to api
TMP_MODEL_PATH = f"../{MODELS_LOCAL_PATH}/{MODEL_NAME}"


def init():
    pretrained_weights = "gpt2"
    tokenizer = GPT2TokenizerFast.from_pretrained(pretrained_weights)
    logger = logging.getLogger(__name__)

    # download model from s3 to local model_path
    if os.getenv("environment") != "local":
        s3_client = boto3.client("s3")
        s3_client.download_file(
            S3_ARTIFACT_BUCKET_NAME, f"{S3_PREFECT_PATH}/{MODELS_PATH}/{MODEL_NAME}", TMP_MODEL_PATH
        )
    return tokenizer, logger


tokenizer, logger = init()


@app.get("/")
def root():
    print("Root Endpoint...")
    logger.warning("Root Endpoint...")
    return {"Hello": "Welcome to the Poetry Generator"}


@app.post("/poem/")
def create_item(poem_features: PoemFeatures):
    print("Create Poem Endpoint...")
    logger.warning("Create Poem Endpoint...")
    created_poem = create_poem(baseline=poem_features.baseline)
    logger.warning(f"Create Poem task is completed with: {type(created_poem)}, {create_poem}")
    out = {"poem": created_poem}
    logger.warning(f"The api response create-poem with: {type(out)}, {out}")
    return out

@app.post("/poem2/")
def create_item(poem_features: PoemFeatures):
    out = {"poem": poem_features.baseline}
    return out


def create_poem(baseline: str):
    baseline_ids = tokenizer.encode(baseline)
    inp = trch.as_tensor(baseline_ids)[None]

    # learn = load_learner(learn_path)
    # preds = learn.model.generate(inp, max_length=60, num_beams=5, no_repeat_ngram_size=2, early_stopping=True)
    model = trch.load(TMP_MODEL_PATH)
    print("Model is loaded from local")
    logger.warning(f"Model is loaded from local {type(model)}")
    preds = model.generate(
        inp, max_length=60, num_beams=5, no_repeat_ngram_size=2, early_stopping=True
    )
    print("Predictions are generated")
    logger.warning(f"Predictions are generated {type(preds)}")
    return tokenizer.decode(preds[0].numpy(), skip_special_tokens=True)


# create_poem(baseline="I don't know what I would do")
# create_poem(baseline="love is ridiculous")
