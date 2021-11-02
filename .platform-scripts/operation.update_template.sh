#!/usr/bin/env bash

# Prepare the auto-update tools.
.platform-scripts/prepare_updater.sh

# Run the update.
auto-update $TEMPLATE_PROFILE update

# Track the update.
date > last_updated_on

# Stage and commit updates.
git add .
git commit -m "auto-update" --allow-empty
