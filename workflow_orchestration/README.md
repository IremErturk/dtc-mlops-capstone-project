# Workflow Orchestration with Prefect

In this module Prefect is used to orchestrate two flows in our MLOps setup.
- datalake_flow: Downloads data from kaggle dataset and store it locally or s3 depending on environment variables.
- model_flow: Reads raw data and apply tokenization and model traing techniques and store the model file locally or s3 depending on environment variables.


##  Local Development

1. Navigate to `workflow_orchestration` folder

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
        # AWS & Terraform Secrets
        AWS_ACCESS_KEY_ID=xxxxxxxxxxxx
        AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxx
        AWS_REGION="eu-central-1"

        # Kaggle Data Resource
        KAGGLE_USERNAME=xxxxxxxxxxxx
        KAGGLE_KEY=xxxxxxxxxxxx

        # Prefect Cloud Secrets
        PREFECT_ACCOUNT_ID=xxxxxxxxxxxx
        PREFECT_WORKSPACE_ID=xxxxxxxxxxxx
        PREFECT_API_KEY=xxxxxxxxxxxx

        environment="local" # local for using the local files in artifacts folder
    ```
    - Create `.env` file inside the `workflow-orchestration` module.
    - Add `KAGGLE_USERNAME` and `KAGGLE_KEY` values to the `.env` file. Follow [instructions](https://www.kaggle.com/general/51898) to find kaggle username, and kaggle key values.
    - Add `PREFECT_ACCOUNT_ID`, `PREFECT_WORKSPACE_ID` and `PREFECT_API_KEY` values to the `.env` file. Follow [instructions](https://docs.prefect.io/ui/cloud-getting-started/) to create API key and workspace in [Prefect Cloud](https://app.prefect.cloud/).


5. Run the flows from terminal

Ensure, the prefect server/instance up and running in your local machine.

```bash
# (option A) Start the Prefect Orion Instance (prefect orion)
prefect orion start

# (option B) Configure Prefect Cloud on Terminal
prefect cloud login -k <PREFECT_API_KEY> (prefect cloud)

# Run the flow standalone
python <flow-name>.py

# Run the deployment for datalake_flow
poetry run prefect deployment build flows/datalake_flow.py:datalake_flow \
        --name cicd \
        --work-queue prefect-agent \ 
        --storage-block s3/deployments \
        --output datalake_flow.yaml

poetry run prefect deployment build flows/model_flow.py:model_flow \
        --name cicd \
        --work-queue prefect-agent \ 
        --storage-block s3/deployments \
        --output model_flow.yaml
```


## Cloud Development

1. Create common Cloud Resources.
    Please ensure to follow instructions in infrastructure/README to create common resources such as artifact bucket. 
2. Create Prefect Cloud Resources
    For deploying the prefect-agent in AWS resources, the cloud resources should be created by cloudformation template `infrastructure/templates/ecs_cluster_prefect_agent.yml` file. The creation of prefect specific resources is automated with the GitHub Actions workflow [`prefect-workflow-creation.yml`](../.github/workflows/prefect-infra-creation.yml). The workflow needs to be triggered manually by GitHub Actions UI. 
    - Requirement: Ensure you have set your Github repository secrets as described [here](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-encrypted-secrets-for-your-repository-and-organization-for-github-codespaces fo all mentioned environment variables in local development section. 
3. Create Prefect Deployments from flows
    By `prefect-workflow-deployment.yml` create the deployments in the prefect-agent and run the workflows in aws-powered agent. The pipeline might fail on step `Deploy flows to S3` therefore if you encounter such a problem you can run the flow by following commands 

    ```bash
    # Run datalake_flow
    poetry run prefect deployment build flows/datalake_flow.py:datalake_flow --name cicd --work-queue prefect-agent --storage-block s3/deployments --output datalake_flow.yaml

    # Run model_flow
    poetry run prefect deployment build flows/model_flow.py:model_flow --name cicd --work-queue prefect-agent --storage-block s3/deployments --output model_flow.yaml
    ```



## Future Work: Alternative Dataset and Approaches 
- [Complete poetryfoundation.org dataset](https://www.kaggle.com/datasets/johnhallman/complete-poetryfoundationorg-dataset/code)
- [PoemGeneration using Seq2Seq|Memory Networks](https://www.kaggle.com/code/pikkupr/poemgeneration-using-seq2seq-memory-networks)
- [Poem Generation with Transformers](https://www.kaggle.com/code/michaelarman/poem-generation-with-transformers/notebook)
- Check existing websites https://sites.research.google/versebyverse/

### References & Helpful Links
- Anna Gellers' Posts & Github repositories related to Prefect
  - **[dataflow-ops](https://github.com/anna-geller/dataflow-ops)
  - [how-to-cut-your-aws-ecs-costs-with-fargate-spot-and-prefect](https://towardsdatascience.com/how-to-cut-your-aws-ecs-costs-with-fargate-spot-and-prefect-1a1ba5d2e2df)
  - [how-to-deploy-prefect-2-0-flows-to-aws](https://discourse.prefect.io/t/how-to-deploy-prefect-2-0-flows-to-aws/1252)
- [Fast AI Tricks](https://benjaminwarner.dev/2021/10/01/inference-with-fastai)