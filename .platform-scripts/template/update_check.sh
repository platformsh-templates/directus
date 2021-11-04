#!/usr/bin/env bash

# Checks to see if we should run updates
function should_run_update () {
    if [ -z ${PLATFORMSH_CLI_TOKEN+x} ]; then 
        echo "PLATFORMSH_CLI_TOKEN is undefined. Skipping operation."; 
        return 1;
    fi
    if [ -z ${GITHUB_TOKEN+x} ]; then 
        echo "GITHUB_TOKEN is undefined. Skipping operation."; 
        return 1;
    fi
    USERS=$(platform project:curl access | jq -c 'map(select(."_embedded".users[0].email | contains("devrel@internal.platform.sh")))')
    MATCH_USERS=$(echo $USERS | jq -r 'length')
    if [ $MATCH_USERS == 0 ]; then
        echo "Skipping template maintenance."
        echo "See the instructions for adding automatic updates to your project:"
        echo "  -> https://community.platform.sh/t/fully-automated-dependency-updates-with-source-operations/801"
        return 1
    fi
    return 0
}
