ARG PYTHON_VERSION=3.10
FROM prefecthq/prefect:2.1.1-python3.10

RUN apt-get update && \
  apt-get install -y build-essential curl wget cmake && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip

RUN mkdir -p /opt/prefect-agent/flows

COPY flows/ /opt/prefect-agent/flows/
COPY pyproject.toml poetry.toml poetry.lock /opt/prefect-agent/

WORKDIR /opt/prefect-agent

RUN curl -sSL https://install.python-poetry.org | python3 - && \
  export PATH=$PATH:$HOME/.local/bin && \
  poetry --version && \
  poetry install --no-dev