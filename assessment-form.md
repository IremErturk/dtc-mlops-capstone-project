
## Peer review criteria / Assessment Criteria

* Problem description
    * 0 points: Problem is not described
    * 1 point: Problem is described but shortly or not clearly
    * [g] 2 points: Problem is well described and it's clear what the problem the project solves
* Cloud
    * 0 points: Cloud is not used, things run only locally
    * 2 points: The project is developed on the cloud
    * [g] 4 points: The project is developed on the cloud and IaC tools are used for provisioning the infrastructure
* Experiment tracking and model registry
    * 0 points: No experiment tracking or model registry
    * 2 points: Experiments are tracked or models are registred in the registry
    * 4 points: Both experiment tracking and model registry are used
* Workflow orchestration
    * 0 points: No workflow orchestration
    * 2 points: Basic workflow orchestration
    * [g] 4 points: Fully deployed workflow  -> Dagster
* Model deployment
    * 0 points: Model is not deployed
    * 2 points: Model is deployed but only locally
    * [g] 4 points: The model deployment code is containerized and could be deployed to cloud or special tools for model deployment are used
* Model monitoring
    * 0 points: No model monitoring
    * 2 points: Basic model monitoring that calculates and reports metrics
    * 4 points: Comprehensive model monitoring that send alerts or runs a conditional workflow (e.g. retraining, generating debugging dashboard, switching to a different model) if the defined metrics threshold is violated
* Reproducibility
    * 0 points: No instructions how to run code at all
    * 2 points: Some instructions are there, but they are not complete
    * [g] 4 points: Instructions are clear, it's easy to run the code, and the code works
* Best practices
    * [op] There are unit tests (1 point)
    * [ ] There is an integration test (1 point)
    * [g] Linter and/or code formatter are used (1 point)
    * [ ] There's a Makefile (1 point)
    * [g] There are pre-commit hooks (1 point)
    * [g] There's a CI/CI pipeline (2 points)
