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
    # Run the update.
    source ~/.environment
    auto-update $TEMPLATE_PROFILE update

    # Track the update.
    date +"%d %B, %Y" > last_updated_on

    # Stage and commit updates.
    git add .
    git commit -m "auto-update" --allow-empty
fi
