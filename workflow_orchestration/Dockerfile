ARG PYTHON_VERSION=3.10
ARG PREFECT_VERSION=2.4.5

FROM prefecthq/prefect:2.4.5-python3.10

RUN apt-get update && \
  apt-get install -y build-essential curl wget cmake && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip

RUN mkdir -p /opt/workflow_orchestration/repo

COPY flows/ /opt/workflow_orchestration/repo/flows/
COPY pyproject.toml poetry.toml poetry.lock constants.py /opt/workflow_orchestration/repo/

WORKDIR /opt/workflow_orchestration/repo

ENV PYTHONUNBUFFERED=1 \
    PIP_DEFAULT_TIMEOUT=100

RUN curl -sSL https://install.python-poetry.org | python3 - && \
  export PATH=$PATH:$HOME/.local/bin && \
  poetry --version && \
  poetry install --no-dev

ENV PATH=/opt/workflow_orchestration/repo/.venv/bin:$PATH

# WORKDIR /opt/workflow_orchestration/repo
RUN mkdir -p ../../artifacts/raw_data
RUN mkdir -p ../../artifacts/models