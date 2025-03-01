#!/bin/bash
# thanks to https://github.com/spameier/proton-bridge-docker

set -ex

BRIDGE="/protonmail/proton-bridge --cli"
BRIDGE_EXTRA_ARGS="--log-level info"
FIFO="/fifo"
VERSION_INFO="/protonmail/version-info.json"

# echo bridge_version from version-info.json
if [[ $1 == version ]]; then
    cat ${VERSION_INFO} | jq -r '.bridge_version'
    cat ${VERSION_INFO} | jq -r '.bridge_release_name'
    exit 0
fi

# Initialize
if [[ $1 == init ]]; then

# call init-bridge script
. ./init-bridge.sh

else

    # initialize pass if necessary
    if ! [ -d "/root/.password-store" ] || ! [ -d "/root/.cache/protonmail/bridge" ]; then
        echo "Run init-bridge first"
    else
        # keep stdin open
        [ -e ${FIFO} ] || mkfifo ${FIFO}
        cat ${FIFO} | ${BRIDGE} ${BRIDGE_EXTRA_ARGS}
    fi
fi
