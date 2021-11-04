#!/usr/bin/env bash

if [ -z ${PLATFORMSH_CLI_TOKEN+x} ]; then 
    echo "PLATFORMSH_CLI_TOKEN is undefined. Skipping operation."; 
else 
    # Replace with UPDATE_ENVIRONMENT?
    if [ "$PLATFORM_ENVIRONMENT_TYPE" = production ]; then
        # Verify project.
        USERS=$(platform project:curl access | jq -c 'map(select(."_embedded".users[0].email | contains("devrel@internal.platform.sh")))')
        MATCH_USERS=$(echo $USERS | jq -r 'length')
        if [ $MATCH_USERS == 0 ]; then
            echo "Skipping template maintenance."
            echo "See the instructions for adding automatic updates to your project:"
            echo "  -> https://community.platform.sh/t/fully-automated-dependency-updates-with-source-operations/801"
        else
            # Run the update.
            auto-update $TEMPLATE_PROFILE update

            # Track the update.
            date +"%d %B, %Y" > last_updated_on

            # Stage and commit updates.
            git add .
            git commit -m "auto-update" --allow-empty
        fi
    fi;
fi
