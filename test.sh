#!/usr/bin/env bash

curl --location --request POST --header "Authorization: Bearer $TOKEN" \
    --header 'Content-Type: application/json' \
    --data-raw '{"state": "failure", "target_url": "https://console.platform.sh/projects/o3fc5w4n5iumy/pr-34/log/2tz7hilzaqgom", "context": "platformsh", "description": "View the logs for the failed activity."}' \
    https://api.github.com/repos/platformsh-templates/directus/statuses/c794f385ee53bbb0888ae75efe34f803dec1b873


    # 'https://api.github.com/repos/${{ github.repository }}/statuses/${{ github.event.commit.sha }}'
