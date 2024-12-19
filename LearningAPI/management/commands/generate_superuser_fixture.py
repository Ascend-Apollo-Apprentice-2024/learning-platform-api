import os
import json
from django.core.management.base import BaseCommand
from django.utils.timezone import now
import sys
from django.contrib.auth.hashers import make_password

class Command(BaseCommand):
    help = "Generate a JSON file for the superuser using environment variables"

    def handle(self, *args, **kwargs):
        # Get environment variables
        username = os.getenv("SUPERUSER_USERNAME")
        password = make_password(os.getenv("SUPERUSER_PASSWORD"))

        if not username or not password:
            raise ValueError("Environment variables SUPERUSER_USERNAME and SUPERUSER_PASSWORD are required")

        # Superuser JSON structure
        fixture = [
            {
                "model": "auth.user",
                "pk": None,
                "fields": {
                    "password": password,
                    "last_login": None,
                    "is_superuser": True,
                    "username": username,
                    "first_name": "Admina",
                    "last_name": "Straytor",
                    "email": "me@me.com",
                    "is_staff": True,
                    "is_active": True,
                    "date_joined": now().isoformat(),
                    "groups": [2],
                    "user_permissions": []
                }
            }
        ]


        json.dump(fixture, sys.stdout, indent=4)
