#!/usr/bin/env bash

if [ $PLATFORM_ENVIRONMENT_TYPE = production ]; then
    timeout 1800 auto-update $TEMPLATE_PROFILE trigger_update_dependencies;
fi;
