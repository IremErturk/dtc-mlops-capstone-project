# Model Serving with Fast API

In this module, previously created machine learning model is server as a api. The api expects to receive `baseline:str` as an input and returns an generated poem based on the given baseline. Please keep in mind the model is in beginning state therefore the generetaed poem might not be super impressive :) 
## Local Development Web-Service

1. Navigate to `model_serving/web_service` folder

2. Intall required packages
    ```bash
    # Create python environment and install requirements
    poetry install
    ```
3. Activate the python environment
    ```bash
    source .venv/bin/activate
    ```
4. Setup environment Variables in  `.env` file.
    ```bash
    AWS_ACCESS_KEY_ID=xxxxxxxxxxxx
    AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxx
    AWS_REGION="eu-central-1"
    environment="local" # local for using the local files in artifacts folder
    ```

5. Run the fastapi_app.py with Uvicorn
    ```bash
    # local run
    uvicorn fastapi_app:app --reload
    ```
6. Check the available endpoint and documentation in `http://127.0.0.1:8000/docs`


## Cloud Deployment

0. Create required Cloud Resources
For deploying the fastapi model serving service, the cloud resources should be created by terraform code in `infrastructure` folder. 
If you are not sure how to generate the resources please check the [README](../infrastructure/README.md)

1. Push `Dockerfile` to AWS ECR by using GitHub Action [build-model-serving](../.github/workflows/build-model-serving.yml)
   1. Requirement: create Github Secrets as described [here](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-encrypted-secrets-for-your-repository-and-organization-for-github-codespaces) and add your `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
   2. Trigger the workflow `Build & Deploy FastAPI Model Serving to Amazon ECS` via GitHub Actions UI


### Dockerize the Web Service App

```bash

# Build Docker image
docker build -t fastapi-app .

# Check docker image
docker images

# Run docker image
# docker run -dp <host_port:docker_port> <name_of_image>
# -d - Detached mode, runs in the background
# -p - to map the port on where do you want to access the #application in my case localhost:8000/
# We have exposed port 8000 in our Dockerfile so we're good to go.

docker run --env-file .env -p 8000:8000 fastapi-app # with environment variables
```


## Request via Terminal
    ```bash
    # endpoint_aws: <application_loadbalancer_dns_name>
    # endpoint_local: localhost:8080
    curl -X 'POST' \                           
    'https://<endpoint>/poem/' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{"baseline": "Love is ridiculuos"}'
    ```