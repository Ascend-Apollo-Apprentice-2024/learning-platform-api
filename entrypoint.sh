#!/bin/bash
set -eu

# Activate Python environment
source "$(pwd)/venv/bin/activate"

# Start PostgreSQL service
if command -v systemctl &> /dev/null; then
    sudo systemctl start postgresql
else
    sudo service postgresql start
fi

# Run migrations and load data
python3 manage.py migrate
python3 manage.py loaddata socialaccount
python3 manage.py loaddata complete_backup

# Start Django development server
python3 manage.py runserver 0.0.0.0:8000
