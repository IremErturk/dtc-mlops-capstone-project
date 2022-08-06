# mlops-capstone-project
Capstone project for Data Talks MLOps Zoomcamp

## Setting up Development Environment

### Python Package Management with Poetry

Poetry is Python Package Management tool that helps managing package dependencies.

1. Install poetry as described in the [Poetry installation](https://python-poetry.org/docs/#installation) section

2. Install packages based on defined versions in either `pyproject.toml` or `poetry.lock`. If you are interested to know details , please check [Installing Dependencies](https://python-poetry.org/docs/basic-usage/#installing-dependencies) section.
    ```bash
    poetry install
    ```

3. Activate the poetry environment
    ```bash
    source {path_to_venv}/bin/activate
    ```

4. To add new packages to the poetry environment. Check the [official documentation](https://python-poetry.org/docs/cli/#add) if you are unsure of usage
    ```bash
    poetry add <package-name><condition><version>
    ```

### Pre-Commit Hooks

Pre-Commit allows to run hooks on every commit automatically to point out issues such as missing semicolons, trailing whitespaces, etc.

1. Install pre-commit as described in the [installation](https://pre-commit.com/) section

2. Pre-Commit configuration file is already configured in `.pre-commit-config.yaml`

3. Running Pre-Commit on the repository, can be done in two different approach

    3.1.  Run on each commit, in that case, the hook scripts would not allow you to push your changes in GitHub
    and inform your code success after each commit. For enabling that you need to initiate that once on the repository level as following  
    ```bash
        pre-commit install
     ```

    3.2. Run agains each file, allow you freedom to run hooks when you want, in that case there is no guarantee that each commit fits the coding
    standards that you defined in  precommit configuration. But you can run against all of the files, whenever you want.
    ```bash
        pre-commit run --all-files
    ```