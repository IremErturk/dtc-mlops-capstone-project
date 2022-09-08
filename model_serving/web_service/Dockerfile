ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION} AS foundation

RUN apt-get update && \
  apt-get install -y build-essential curl wget cmake && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip

RUN mkdir -p /opt/web_service/repo

COPY fastapi_app.py constants.py /opt/web_service/repo/
COPY pyproject.toml poetry.toml poetry.lock /opt/web_service/repo/

WORKDIR /opt/web_service/repo

RUN curl -sSL https://install.python-poetry.org | python3 - && \
  export PATH=$PATH:$HOME/.local/bin && \
  poetry --version && \
  poetry install --no-dev

FROM python:${PYTHON_VERSION}-slim
COPY --from=foundation /opt/web_service/repo /opt/web_service/repo
ENV PATH=/opt/web_service/repo/.venv/bin:$PATH

ENV PYTHONUNBUFFERED 1
WORKDIR /opt/web_service/repo
RUN mkdir -p ../../artifacts/models

EXPOSE 8000

CMD ["uvicorn", "--host", "0.0.0.0", "--port", "8000", "fastapi_app:app"]
