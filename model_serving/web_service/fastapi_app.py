from typing import Union

from fastapi import FastAPI
from pydantic import BaseModel


class PoemFeatures(BaseModel):
    baseline: str
    form: Union[str, None] = None
    topic: Union[str, None] = None
    author: Union[str, None] = None


app = FastAPI()


@app.get("/")
def root():
    return {"Hello": "Welcome to the Poetry Generator"}


@app.post("/poem/")
async def create_item(poem_features: PoemFeatures):
    # do things with poem_features and model stored ..
    prediction = {"poem": poem_features.baseline}
    return prediction
