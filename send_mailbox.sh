#!/usr/bin/env bash

curl -X PUT -H "Content-Type: application/json" --data "{\"message\": \"$1\", \"topic\":  \"spotify_progress\"}" http://ledstrip/api/mailbox.json

