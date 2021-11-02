#!/usr/bin/env bash

pip3 install setuptools
pip3 install wheel
pip3 install git+git://github.com/platformsh/template-builder.git#egg=template-builder

auto-update platform install_cli
auto-update $TEMPLATE_PROFILE update

date > last_updated_on

git add .
git commit -m "auto-update" --allow-empty