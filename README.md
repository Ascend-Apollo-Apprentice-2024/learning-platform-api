# Learning Platform Project

## Installs Needed

### Learning Platform Request Collection

1. Install [Postman](https://www.postman.com/downloads/)
1. Open Postman app
1. Click Import from the navbar
1. Choose the Link option
1. Paste in this URL: https://api.postman.com/collections/1447661-3b2a6280-fb27-48e1-ab65-ad22c45fd54b?access_key=PMAT-01HHFR8YTSD5PVR5KSQN976T4N
1. You should be prompted to import LearnOps Collection.
1. Click the Import button to complete the process.

## Getting Started

1. Fork this repo to your own Github account.
2. Clone it.
3. `cd` into the project directory.
4. Run `pipenv shell` to create a virtual environment.

## Github OAuth App

1. Go to your Github account settings
2. Open **Developer Settings**
3. Open **OAuth Apps**
4. Click **New OAuth App** button
5. Application name should be **Learning Platform**
6. Homepage URL should be `http://localhost:3000`
7. Enter a description if you like
8. Authorization callback should be `http://localhost:8000/auth/github/callback`
9. Leave **Enable Device Flow** unchecked
10. Create the app and **do not close** the screen that appears
11. Go to Github and click the **Generate a new client secret** button
12. **DO NOT CLOSE TAB. CLIENT AND SECRET NEEDED BELOW.**

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

### Install and Configure Postgres

In your Ubuntu terminal run the following command to initiate the installation and configuration of the Learning Platform. It will install the correct version of Python, PostgreSQL and then run migrations to create tables, and finally load fixtures to seed the database with sample data.

If you are on PC:
```sh
./linuxInstall-dev.sh -d=$LEARN_OPS_DB \
    -u=$LEARN_OPS_USER \
    -p=$LEARN_OPS_PASSWORD \
    -r=$LEARN_OPS_SUPERUSER_NAME \
    -j=$LEARN_OPS_SUPERUSER_PASSWORD \
    -c=$LEARN_OPS_CLIENT_ID \
    -s=$LEARN_OPS_SECRET_KEY
```

When prompted to "remove write-protected regular file './LearningAPI/fixtures/superuser.json'?" type `y`

If you are on mac:
```sh
./macInstall-dev.sh -d=$LEARN_OPS_DB \
    -u=$LEARN_OPS_USER \
    -p=$LEARN_OPS_PASSWORD \
    -r=$LEARN_OPS_SUPERUSER_NAME \
    -j=$LEARN_OPS_SUPERUSER_PASSWORD \
    -c=$LEARN_OPS_CLIENT_ID \
    -s=$LEARN_OPS_SECRET_KEY
```
## Testing the Installation

1. Start the API in debug mode in Visual Studio Code.
1. Visit http://localhost:8000/admin
1. Authenticate with the superuser credentials you created previously and then you can view all kinds of data that is in your database.

## Make Yourself an Instructor

1. Start the React client application.
1. Authorize the client with Github.
1. Visit http://localhost:8000/admin and authenticate with your superuser credentials.
2. Click on **Users** in the left navigation.
3. Find the account that was just created for your Github authorization by searching for your Github username.
4. Click on your user account.
5. Toggle **Staff status** to be on.
6. In the **Group** sections, double click **Instructor** so that it moves to the _Chosen groups_ list.
7. Close the browser tab that is running the Learning Platform.
8. Open a new tab and visit http://localhost:3000 again and authenticate.
9. You should now see the instructor interface.



## Assets

### ERD

[dbdiagram.io ERD](https://dbdiagram.io/d/6005cc1080d742080a36d6d8)
