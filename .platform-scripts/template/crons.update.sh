#!/usr/bin/env bash

#found out where we are so we can include other files
DIR="${BASH_SOURCE%/*}"
#if BASH_SOURCE didn't return what we want, try PWD
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
#Include our update check.
. "${DIR}/update_check.sh"

should_run_update
run=$?

if (( 0 == run )); then
    # Update the template.
    if [ "$PLATFORM_ENVIRONMENT_TYPE" = production ] && [ -z ${PLATFORM_OUTPUT_DIR+x} ]; then
       timeout 1800 auto-update $TEMPLATE_PROFILE trigger_update_dependencies
    fi
fi
