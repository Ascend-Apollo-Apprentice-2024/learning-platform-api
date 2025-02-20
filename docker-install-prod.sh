#!/bin/bash
set +o histexpand
set -eu

# Ensure Python is installed
if ! command -v python3 &>/dev/null; then
    echo "Python3 not found, installing..."
    sudo apt update -y && sudo apt install python3 python3-pip -y
fi

# Install pyenv if not already installed
if ! command -v pyenv &>/dev/null; then
    echo "pyenv not found, installing..."
    curl https://pyenv.run | bash
    # Add pyenv to shell configuration
    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
    source ~/.bashrc
fi

# Ensure Python 3.9.1 is installed
if pyenv versions --bare | grep -q '^3.9.1$'; then
    echo "Python 3.9.1 is already installed."
else
    echo "Python 3.9.1 not found, installing..."
    pyenv install 3.9.1
fi

# Set Python 3.9.1 as global version
pyenv global 3.9.1

# Install Pipenv if not already installed
if ! command -v pipenv &>/dev/null; then
    echo "Pipenv not found, installing..."
    pip3 install pipenv
fi

# Create and activate virtual environment
export VIRTUAL_ENV="$(pwd)/venv"
python3 -m venv $VIRTUAL_ENV
source $VIRTUAL_ENV/bin/activate

# Install project dependencies
pipenv install --dev

# Set up PostgreSQL
if ! command -v psql &>/dev/null; then
    echo "PostgreSQL not found, installing..."
    sudo apt install postgresql postgresql-contrib -y
    sudo service postgresql start
fi

# Install other dependencies from requirements.txt
pip3 install -r requirements.txt

echo "Installation complete."
