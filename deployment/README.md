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

## Dockerize the Web Service App

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

docker run -dp 8000:8000 fastapi-app
```