#!/usr/bin/env bash

if [ $PLATFORM_ENVIRONMENT_TYPE = production ]; then
    # Prepare the auto-update tools.
    .platform-scripts/prepare_updater.sh

    # Update the template.
    timeout 1800 auto-update $TEMPLATE_PROFILE trigger_update_dependencies;
fi;
