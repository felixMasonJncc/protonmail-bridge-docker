#!/bin/bash
# thanks to https://github.com/spameier/proton-bridge-docker

set -ex

BRIDGE="/protonmail/proton-bridge --cli"
BRIDGE_EXTRA_ARGS="--log-level info"
FIFO="/fifo"

# Initialize
if [[ $1 == init ]]; then

# call init-bridge script
. ./init-bridge.sh

else

# keep stdin open
[ -e ${FIFO} ] || mkfifo ${FIFO}
cat ${FIFO} | ${BRIDGE} ${BRIDGE_EXTRA_ARGS}

fi
