# yourapp/management/commands/generate_github_fixture.py
from django.core.management.base import BaseCommand
import json
import os
import sys

class Command(BaseCommand):
    help = 'Outputs GitHub OAuth credentials as JSON fixture'

    def handle(self, *args, **options):
        client_id = os.environ.get('OAUTH_CLIENT_ID')
        secret_key = os.environ.get('OAUTH_SECRET_KEY')

        if not client_id or not secret_key:
            raise ValueError("Required environment variables OAUTH_CLIENT_ID and/or OAUTH_SECRET_KEY are not set")

        fixture = [
            {
                "model": "socialaccount.socialapp",
                "pk": 1,
                "fields": {
                    "provider": "github",
                    "name": "Github",
                    "client_id": client_id,
                    "secret": secret_key,
                    "key": "",
                    "sites": [1]
                }
            }
        ]

        json.dump(fixture, sys.stdout, indent=4)