#!/usr/bin/env bash

if [ $PLATFORM_ENVIRONMENT_TYPE = production ]; then
    auto-update $TEMPLATE_PROFILE trigger_update_dependencies;
fi;
