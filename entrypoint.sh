#!/bin/bash

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
' > /app/LearningAPI/fixtures/socialaccount.json

# Run the default command
exec "$@"
