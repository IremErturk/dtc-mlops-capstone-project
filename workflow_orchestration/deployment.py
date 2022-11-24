from datetime import timedelta
import os
from dotenv import load_dotenv

from constants import (
    S3_ARTIFACT_BUCKET_NAME
)
from flows import model_flow

from prefect.filesystems import S3
from prefect.deployments import Deployment
from prefect.orion.schemas.schedules import IntervalSchedule


load_dotenv()


bucket_name = S3_ARTIFACT_BUCKET_NAME

def get_storage(s3_bucket: str):
    if os.getenv("environment") == "local":
        return None
    else:
        block = S3(bucket_path=s3_bucket, 
            aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"))
        try:
            block.save("prefect-artifacts")
        except:
            pass    
        return block


deployment_mlflow = Deployment.build_from_flow(
    flow= model_flow,
    name = "Model Training flow",
    work_queue_name = "prefect-agent",
    infra_overrides = {
        "env": {
            "AWS_ACCESS_KEY_ID": os.getenv("AWS_ACCESS_KEY_ID"),
            "AWS_SECRET_ACCESS_KEY": os.getenv("AWS_SECRET_ACCESS_KEY"),
            "AWS_DEFAULT_REGION": os.getenv("AWS_REGION")
        }
    },
    storage = get_storage(bucket_name),
    schedule = IntervalSchedule(interval=timedelta(minutes=5)),
    tags = ["model-training"],
    # flow_runner=SubprocessFlowRunner(),
)

deployment_mlflow.apply()
