#!/usr/bin/env bash

# Prepare the auto-update tools.
pip3 install setuptools
pip3 install wheel
pip3 install git+https://github.com/platformsh/template-builder.git#egg=template-builder
auto-update platform install_cli
