

## Setup

### Local Development

1. Python Environment with Poetry.

Prerequisite: Poetry is installed on the your local machine. Please follow the [official-instructions](https://python-poetry.org/docs/) to install Poetry.

```bash
cd workflow-orchestration
poetry install -v
```
```bash
source ./.venv/bin/activate  
```

2. Environment Variables
- Create `.env` file inside the `workflow-orchestration` module.
- Add `KAGGLE_USERNAME` and `KAGGLE_KEY` values to the `.env` file. Follow [instructions](https://www.kaggle.com/general/51898) here to find kaggle username, and kaggle key values.


3. Run the flows from terminal

Ensure, the prefect server/instance up and running in your local machine.

```bash
# Start the Prefect Orion Instance
prefect orion start

# Run the flow
python <flow-name>.py
```


- Task runners
- Flow @flow -> create flow runs
    - Parametrize the flows...
- Prefect Deployment ? -> and association witn the Flow
Flows are required for deployments — every deployment points to a specific flow as the entrypoint for a flow run.

A deployment is a server-side concept that encapsulates a flow, allowing it to be scheduled and triggered via API. The deployment stores metadata about where your flow's code is stored and how your flow should be run.
