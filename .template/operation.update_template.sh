#!/usr/bin/env bash

# Prepare the auto-update tools.
pip3 install setuptools
pip3 install wheel
pip3 install git+git://github.com/platformsh/template-builder.git#egg=template-builder
auto-update platform install_cli

# Run the update.
auto-update $TEMPLATE_PROFILE update

# Track the update.
date > last_updated_on

# Stage and commit updates.
git add .
git commit -m "auto-update" --allow-empty
