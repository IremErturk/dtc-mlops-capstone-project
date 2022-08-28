## Local Development Web-Service

Intall required packages

```bash
# Create python environment and install requirements
poetry install
```

```bash
# local run
uvicorn fastapi_app:app --reload
```

Check the fastapi auto created documentation by `http://127.0.0.1:8000/docs`
