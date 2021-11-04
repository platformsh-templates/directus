#!/usr/bin/env bash

install_cli () {
    auto-update platform install_cli
}

install_updater () {
    pip3 install setuptools
    pip3 install wheel
    pip3 install git+https://github.com/platformsh/template-builder.git#egg=template-builder
}

install () {
    if [ -z ${PLATFORMSH_CLI_TOKEN+x} ] && [ -z ${GITHUB_TOKEN+x} ]; then 
        echo "Build hook completed on user project."
    else 
        install_updater
        install_cli
    fi
}

install
