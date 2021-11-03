#!/usr/bin/env bash

if [ -z ${PLATFORMSH_CLI_TOKEN+x} ]; then 
    echo "PLATFORMSH_CLI_TOKEN is undefined. Skipping installation."; 
else 
    if [ $PLATFORM_ENVIRONMENT_TYPE = production ]; then
        # Prepare the auto-update tools.
        .platform-scripts/template/prepare_updater.sh

        # Verify project.
        USERS=$(platform project:curl access | jq -c 'map(select(."_embedded".users[0].email | contains("devrel@internal.platform.sh")))')
        MATCH_USERS=$(echo $USERS | jq -r 'length')
        if [ $MATCH_USERS == 0 ]; then
            echo "Skipping template maintenance."
            echo "See the instructions for adding automatic updates to your project:"
            echo "  -> https://community.platform.sh/t/fully-automated-dependency-updates-with-source-operations/801"
        else
            # Update the template.
            timeout 1800 auto-update $TEMPLATE_PROFILE trigger_update_dependencies;
        fi
    fi;
fi
