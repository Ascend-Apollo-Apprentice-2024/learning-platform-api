#!/bin/bash
set +o histexpand
set -eu

#Takes parameters we pass in and sets them as local variables
for i in "$@"
do 
case $i in 
    -d=*|--database=*) DATABASE="${i#*=}" ;;
    -u=*|--user=*) USER="${i#*=}" ;;
    -p=*|--password=*) PASSWORD="${i#*=}" ;;
    -c=*|--clientid=*) CLIENTID="${i#*=}" ;;
    -s=*|--secretkey=*) SECRETKEY="${i#*=}" ;;
    -j=*|--superpass=*) SUPERPASS="${i#*=}" ;;
    -r=*|--superuser=*) SUPERUSER="${i#*=}" ;;
    *) # unkown option ;;
esac
done

# update apt(package manager for ubuntu)
# sudo apt update -y

# Check to see if pyenv is already installed, if so skip installation of pyenv
# &> the & is wildcard, meaning all output in this case, 1 is standard output, 2 is error output
if command -v pyenv &>/dev/null; then
    echo "pyenv is installed."
else
    # install dependency packages that are necessary to install pyenv on WSL Ubuntu environment
    sudo apt install -y curl git build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl
    # install pyenv on WSL Ubuntu environment
    curl https://pyenv.run | bash

    #check if .zshrc startup script exists, if not create it
    if [ -f $HOME/.zshrc ]; then
        # add necessary config to shell profile (.zshrc)
        echo 'export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv virtualenv-init -)"' >> $HOME/.zshrc
    else
        # add necessary config to shell profile (.bashrc)
        echo 'export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv virtualenv-init -)"' >> $HOME/.bashrc
    fi


    # update path of current subshell execution
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv virtualenv-init -)"
fi
# Check if python 3.9.1 is installed, if not install it
     # Check if Python 3.9.1 is installed
  if pyenv versions --bare | grep -q '^3.9.1$'; then
    echo "Python 3.9.1 is already installed."
  else
    echo "Python 3.9.1 is not installed. Installing now..."
    pyenv install 3.9.1
fi
# Check that global version of python is 3.9.1
# Get the global Python version set in pyenv
  global_version=$(pyenv global)
  if [[ $global_version == '3.9.1' ]]; then
    echo "Python 3.9.1 is the global version."
  else
    echo "Python 3.9.1 is not the global version. The global version is $global_version."
    echo "Setting global version of python to 3.9.1"
    # Set Python 3.9.1 as the global version
    pyenv global 3.9.1
  fi

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null
then
    echo "PostgreSQL is not installed"
    sudo apt install git curl python3-pip postgresql postgresql-contrib -y
    # Do we need to start this here?
    


    # Check if systemctl command exists
if command -v systemctl &> /dev/null; then
    # Start PostgreSQL using systemctl
    sudo systemctl start postgresql
else
    # Start PostgreSQL using service (fallback)
    sudo service postgresql start
fi

fi

# drop database before it's created
sudo su - postgres <<COMMANDS
psql -c "DROP DATABASE IF EXISTS $DATABASE WITH (FORCE);"
psql -c "CREATE DATABASE $DATABASE;"
psql -c "CREATE USER $USER WITH PASSWORD '$PASSWORD';"
psql -c "ALTER ROLE $USER SET client_encoding TO 'utf8';"
psql -c "ALTER ROLE $USER SET default_transaction_isolation TO 'read committed';"
psql -c "ALTER ROLE $USER SET timezone TO 'UTC';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE $DATABASE TO $USER;"
psql learnopsdev -c "GRANT ALL ON ALL TABLES IN SCHEMA public to $USER;"
psql learnopsdev -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public to $USER;"
psql learnopsdev -c "GRANT ALL ON ALL FUNCTIONS IN SCHEMA public to $USER;"
psql -c "GRANT postgres to $USER;"
psql -c "SELECT * FROM pg_tables ORDER BY tableowner;"
COMMANDS

# Check if Pipenv is installed
if ! command -v pipenv &> /dev/null; then
    echo "Pipenv not found. Installing Pipenv..."
    pip3 install pipenv
    echo "Pipenv installation complete."
else
    echo "Pipenv is already installed."
fi

#Do we need to activate the virtual environment? Possibly.
#use venv to create the virtual env directory
#running venv will create directory called 'venv' in project directory
#python3 -m venv venv 
#get the path of the virtual environment
#create environment variable
export VIRTUAL_ENV="$(pwd)/venv"
echo "VIRTUAL_ENV=$VIRTUAL_ENV" > .env
python3 -m venv $VIRTUAL_ENV
#Activate the virtual environment 'source venv/bin/activate'
source $VIRTUAL_ENV/bin/activate

pip3 install wheel
# Install dependencies from requirements.txt file 
pip3 install -r requirements.txt

# find which version of Postgres is installed
echo "Checking version of Postgres"
VERSION=$( $(sudo find /usr -wholename '*/bin/postgres') -V | (grep -E -oah -m 1 '[0-9]{1,}') | head -1)
echo "Found version $VERSION"
# update /etc/postgresql/{version}/main/pg_hbc.conf SCRAM -> Trust
#####
# Replace `scram-sha-256` with `trust` in the pg_hba file to enable peer authentication
#####
sudo sed -i -e 's/scram-sha-256/trust/g' /etc/postgresql/"$VERSION"/main/pg_hba.conf
# restart postgres service




echo "Generating Django password"
export DJANGO_SETTINGS_MODULE="LearningPlatform.settings"
#takes plain text password and used the utility to encrypt the password
export DJANGO_SETTINGS_MODULE=LearningPlatform.settings
DJANGO_GENERATED_PASSWORD=$(python3 ./djangopass.py "$SUPERPASS" >&1)

sudo tee ./LearningAPI/fixtures/superuser.json <<EOF
[
    {
        "model": "auth.user",
        "pk": null,
        "fields": {
            "password": "$DJANGO_GENERATED_PASSWORD",
            "last_login": null,
            "is_superuser": true,
            "username": "$SUPERUSER",
            "first_name": "Admina",
            "last_name": "Straytor",
            "email": "me@me.com",
            "is_staff": true,
            "is_active": true,
            "date_joined": "2023-03-17T03:03:13.265Z",
            "groups": [
                2
            ],
            "user_permissions": []
        }
    }
]
EOF

# run migrations
echo '[
    {
       "model": "sites.site",
       "pk": 1,
       "fields": {
          "domain": "learningplatform.com",
          "name": "Learning Platform"
       }
    },
    {
        "model": "socialaccount.socialapp",
        "pk": 1,
        "fields": {
            "provider": "github",
            "name": "Github",
            "client_id": "'"$CLIENTID"'",
            "secret": "'"$SECRETKEY"'",
            "key": "",
            "sites": [
                1
            ]
        }
    }
  ]
' > ./LearningAPI/fixtures/socialaccount.json

echo "About to run migrations"

# Run existing migrations
python3 manage.py migrate

echo "loading data from backup"

# Load data from backup
python3 manage.py loaddata socialaccount
python3 manage.py loaddata complete_backup

#delete ./LearningAPI/fixtures/socialaccount.json
rm ./LearningAPI/fixtures/socialaccount.json
