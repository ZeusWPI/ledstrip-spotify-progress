#!/usr/bin/env bash

xh put http://ledstrip/api/mailbox.json topic=spotify_progress message="$1"

