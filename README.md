# Learning Platform Project

## Installs Needed

### Learning Platform Request Collection

1. Install [Postman](https://www.postman.com/downloads/)
1. Open Postman app
1. Click Import from the navbar
1. Choose the Link option
1. Paste in this URL: <https://api.postman.com/collections/1447661-3b2a6280-fb27-48e1-ab65-ad22c45fd54b?access_key=PMAT-01HHFR8YTSD5PVR5KSQN976T4N>
1. You should be prompted to import LearnOps Collection.
1. Click the Import button to complete the process.

## System Requirements

1. Ensure that your system has the required build dependencies.
2. Follow instructions to install homebrew for mac: [Homebrew Installation](https://docs.brew.sh/Installation)
3. Follow instructions to install Ubuntu for windows: [Ubuntu Installation](https://apps.microsoft.com/detail/9pdxgncfsczv?rtc=1&hl=en-us&gl=US)


### Ubuntu/Debian-based systems

```bash
sudo apt-get update
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

## Installing Pyenv

1. the recommended method to install `pyenv` is to use the `pyenv-installer` script or clone the `pyenv` repository directly from GitHub.

### Using `pyenv-installer`

```bash
curl https://pyenv.run | bash
```

### Cloning directly

```bash
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
```

## Setup Environment Variables

After installation, you need to configure the environment variables. Add the following lines to your shell's startup script (.bashrc, .zshrc, etc.):

```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"
```

After adding these lines, restart your shell or source the startup script (e.g., source ~/.bashrc).

## Verify Installation

To verify that pyenv is installed correctly, use:

```bash
pyenv --version
```

## Install Python Versions

With pyenv installed, you can now install multiple versions of Python. Look in the `.python-version` file to refer to the current version of Python being used.

```bash
pyenv install {python version}
```

## Github OAuth App

1. Go to your Github account settings
2. Open **Developer Settings**
3. Open **OAuth Apps**
4. Click **Register A New Application** button
5. Application name should be **Learning Platform**
6. Homepage URL should be `http://localhost:3000`
7. Enter a description if you like
8. Authorization callback should be `http://localhost:8000/auth/github/callback`
9. Leave **Enable Device Flow** unchecked
10. Create the app and **do not close** the screen that appears
11. Go to Github and click the **Generate a new client secret** button
12. **DO NOT CLOSE TAB. CLIENT AND SECRET NEEDED BELOW.**

## Environment Variables

Several environment variables need to be set up by you to make the setup process faster and more secure.

### Install Django

```sh
pip install django
```

### Django Secret Key

You will need a Django secret key environment variable. Run the following command in your terminal to generate one and save it for later.

```sh
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### All Variables Needed

Set up the following environment variables anywhere in your shell initialization file _(i.e. `.bashrc` or `.zshrc`)_.

```sh
export LEARN_OPS_DB=learnopsdev
export LEARN_OPS_USER=learnopsdev
export LEARN_OPS_PASSWORD=DatabasePasswordOfYourChoice
export LEARN_OPS_HOST=127.0.0.1
export LEARN_OPS_PORT=5432
export LEARN_OPS_CLIENT_ID=GithubOAuthAppClientId
export LEARN_OPS_SECRET_KEY=GithubOAuthAppSecret
export LEARN_OPS_DJANGO_SECRET_KEY="GeneratedDjangoSecretKey"
export LEARN_OPS_ALLOWED_HOSTS="127.0.0.1,localhost"
export LEARN_OPS_SUPERUSER_NAME=AdminUsernameOfYourChoice
export LEARN_OPS_SUPERUSER_PASSWORD=AdminPasswordOfYourChoice
```

### Activate Environment Variables

Then reload your bash session with `source ~/.zshrc` if you are using zshell or `source ~/.bashrc` if you have the default bash environment.

### Create the Database

In the main directory there is a bash script that you can run to create the database and database user needed for the project. You can run the script with the command below.

It will prompt you for your password.


## Linux installs:

1st make sure your user has permissions to run the script.
```bash
chmod +x linux-install-dev.sh
```

- Run the linux-install-dev.sh in the linux terminal:

```bash 
./linux-install-dev.sh \
    -d=$LEARN_OPS_DB \
    -u=$LEARN_OPS_USER \
    -p=$LEARN_OPS_PASSWORD \
    -h=$LEARN_OPS_HOST \
    -P=$LEARN_OPS_PORT \
    -c=$LEARN_OPS_CLIENT_ID \
    -s=$LEARN_OPS_SECRET_KEY \
    -j=$LEARN_OPS_SUPERUSER_PASSWORD \
    -r=$LEARN_OPS_SUPERUSER_NAME
```
## Mac Installs:

1st make sure your user has permissions to run the script.
```bash
chmod +x setup_mac.sh
```

- Run the setup_mac.sh in the linux terminal:

```bash 
./setup_mac.sh \
    -d=$LEARN_OPS_DB \
    -u=$LEARN_OPS_USER \
    -p=$LEARN_OPS_PASSWORD \
    -h=$LEARN_OPS_HOST \
    -P=$LEARN_OPS_PORT \
    -c=$LEARN_OPS_CLIENT_ID \
    -s=$LEARN_OPS_SECRET_KEY \
    -j=$LEARN_OPS_SUPERUSER_PASSWORD \
    -r=$LEARN_OPS_SUPERUSER_NAME
```

## Testing the Installation

1. Start the API in debug mode in Visual Studio Code.
2. Visit <http://localhost:8000/admin>
3. Authenticate with the superuser credentials you created previously and then you can view all kinds of data that is in your database.

## Make Yourself an Instructor

1. Start the React client application.
2. Authorize the client with Github.
3. Visit <http://localhost:8000/admin> and authenticate with your superuser credentials.
4. Click on **Users** in the left navigation.
5. Find the account that was just created for your Github authorization by searching for your Github username.
6. Click on your user account.
7. Toggle **Staff status** to be on.
8. In the **Group** sections, double click **Instructor** so that it moves to the _Chosen groups_ list.
9. Close the browser tab that is running the Learning Platform.
10. Open a new tab and visit <http://localhost:3000> again and authenticate.
11. You should now see the instructor interface.

## Assets

### ERD

[dbdiagram.io ERD](https://dbdiagram.io/d/6005cc1080d742080a36d6d8)
