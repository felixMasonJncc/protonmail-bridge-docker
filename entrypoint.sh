#!/bin/bash
# thanks to https://github.com/spameier/proton-bridge-docker

set -ex

BRIDGE="/protonmail/proton-bridge --cli"
BRIDGE_EXTRA_ARGS="--log-level info"
FIFO="/fifo"

# Initialize
if [[ $1 == init ]]; then

# initialize gpg if necessary
if ! [ -d /root/.gnupg ]; then
  gpg --generate-key --batch << 'EOF'
    %no-protection
    %echo Generating GPG key
    Key-Type:RSA
    Key-Length:2048
    Name-Real:pass-key
    Expire-Date:0
    %commit
EOF
fi

# initialize pass if necessary
if ! [ -d /root/.password-store ]; then
  pass init pass-key
fi

# login to ProtonMail if neccessary
if ! [ -d /root/.cache/protonmail/bridge ]; then
  ${BRIDGE} $@
fi

else

# keep stdin open
[ -e ${FIFO} ] || mkfifo ${FIFO}
cat ${FIFO} | ${BRIDGE} ${BRIDGE_EXTRA_ARGS}

fi
