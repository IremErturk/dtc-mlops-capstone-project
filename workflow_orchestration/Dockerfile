ARG PYTHON_VERSION=3.10
ARG PREFECT_VERSION=2.4.5

FROM prefecthq/prefect:2.4.5-python3.10

RUN apt-get update && \
  apt-get install -y build-essential curl wget cmake && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip

RUN mkdir -p /opt/workflow_orchestration/repo

COPY flows/ /opt/web_service/repo/flows/
COPY pyproject.toml poetry.toml poetry.lock /opt/workflow_orchestration/repo/

WORKDIR /opt/workflow_orchestration/repo

RUN curl -sSL https://install.python-poetry.org | python3 - && \
  export PATH=$PATH:$HOME/.local/bin && \
  poetry --version && \
  poetry install --no-dev

ENV PATH=/opt/workflow_orchestration/repo/.venv/bin:$PATH

ENV PYTHONUNBUFFERED 1
# WORKDIR /opt/workflow_orchestration/repo
RUN mkdir -p ../../artifacts/raw_data
RUN mkdir -p ../../artifacts/models

CMD ["prefect", "agent", "start" , "-q", "workflows"]
