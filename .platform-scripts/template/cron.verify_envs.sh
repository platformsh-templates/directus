#!/usr/bin/env bash

TEMPLATE_NAMESPACE=platformsh-templates

# The GitHub side.
check_branch_exists () {
    STATUS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$TEMPLATE_NAMESPACE/$TEMPLATE_PROFILE/branches/$UPDATE_ENVIRONMENT)
    echo $STATUS | jq -r '.message'
}

get_default_branch_sha () {
    DEFAULT_BRANCH=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$TEMPLATE_NAMESPACE/$TEMPLATE_PROFILE | jq -r '.default_branch')
    SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$TEMPLATE_NAMESPACE/$TEMPLATE_PROFILE/branches/$DEFAULT_BRANCH)
    echo $SHA | jq -r '.commit.sha'
}

create_branch () {
    DEFAULT_BRANCH_SHA=$(get_default_branch_sha)
    UPDATE_BRANCH_REF=refs/heads/$UPDATE_ENVIRONMENT
    echo "Creating $UPDATE_BRANCH_REF from $DEFAULT_BRANCH_SHA"
    DATA=$( jq -n \
                --arg ref "$UPDATE_BRANCH_REF" \
                --arg sha "$DEFAULT_BRANCH_SHA" \
                '{ref: $ref, sha: $sha}' )
    curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" \
        -d "$DATA" \
        https://api.github.com/repos/$TEMPLATE_NAMESPACE/$TEMPLATE_PROFILE/git/refs
    sleep 5
}

# The Platform.sh side.
check_environment_status () {
    UPDATE_ENVIRONMENT_STATUS=$(platform project:curl environments/$UPDATE_ENVIRONMENT | jq -r '.status')
    echo $UPDATE_ENVIRONMENT_STATUS
}

# Verify template project can receive updates.
verify_environments () {
    source ~/.environment
    if [ "$(check_branch_exists)" == "Branch not found" ]; then
        echo "Branch not found. Creating."
        # Create the branch.
        create_branch
        # Activate the environment.
        platform environment:activate $UPDATE_ENVIRONMENT -y --no-wait
    else
        if [ "$(check_environment_status)" == "inactive" ]; then
            echo "Branch found, but environment is inactive. Activating."
            # Activate the environment.
            platform environment:activate $UPDATE_ENVIRONMENT -y --no-wait
        else
            echo "Update branch and environment OK."
        fi
    fi
}

#found out where we are so we can include other files
DIR="${BASH_SOURCE%/*}"
#if BASH_SOURCE didn't return what we want, try PWD
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
#Include our update check.
. "${DIR}/.platform-scripts/template/update_check.sh"

should_run_update
run=$?

if (( 0 == run )); then
    # Verify update environment exists, but only on production cron.
    if [ "$PLATFORM_ENVIRONMENT_TYPE" = production ] && [ -z ${PLATFORM_OUTPUT_DIR+x} ]; then
        verify_environments
    fi
fi
