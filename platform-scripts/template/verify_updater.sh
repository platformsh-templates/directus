#!/usr/bin/env bash

TEMPLATE_NAMESPACE=platformsh-templates
UPDATE_ENVIRONMENT=update

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
    curl -X POST -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" \
        -d "$DATA" \
        https://api.github.com/repos/$TEMPLATE_NAMESPACE/$TEMPLATE_PROFILE/git/refs
    sleep 5
}

# The Platform.sh side.
check_environment_status () {
    UPDATE_ENVIRONMENT_STATUS=$(platform project:curl environments/$UPDATE_ENVIRONMENT | jq -r '.status')
    echo $UPDATE_ENVIRONMENT_STATUS
}

verify_project_is_official_template () {
    USERS=$(platform project:curl access | jq -c 'map(select(."_embedded".users[0].email | contains("devrel@internal.platform.sh")))')
    echo $USERS | jq -r 'length'
}

# Verify template project can receive updates.
verify_environments () {
    if [ "$(check_branch_exists)" == "Branch not found" ]; then
        echo "Branch not found. Creating."
        # Create the branch.
        create_branch
        # Activate the environment.
        platform environment:activate $UPDATE_ENVIRONMENT -y
    else
        if [ "$(check_environment_status)" == "inactive" ]; then
            echo "Branch found, but environment is inactive. Activating."
            # Activate the environment.
            platform environment:activate $UPDATE_ENVIRONMENT -y
        fi
    fi
}

install_update_tools () {
    # Prepare the auto-update tools.
    pip3 install setuptools
    pip3 install wheel
    pip3 install git+https://github.com/platformsh/template-builder.git#egg=template-builder
    auto-update platform install_cli
}

# Main.
verify () {
    if [ -z ${PLATFORMSH_CLI_TOKEN+x} ]; then 
        echo "PLATFORMSH_CLI_TOKEN is undefined. Skipping installation."; 
    else 
        if [ "$PLATFORM_ENVIRONMENT_TYPE" = development ]; then

            # Prepare the auto-update tools.
            install_update_tools

            # Verify official template project.
            STATUS=$(verify_project_is_official_template)
            if [ $STATUS == 0 ]; then
                echo "Skipping template maintenance."
                echo "See the instructions for adding automatic updates to your project:"
                echo "  -> https://community.platform.sh/t/fully-automated-dependency-updates-with-source-operations/801"
            else
                # Verify update environment.
                verify_environments
            fi
        fi
    fi
}

echo "In the script"
verify
