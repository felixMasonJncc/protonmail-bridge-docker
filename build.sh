#!/bin/bash

set -ex

BRANCH=master

# Clone new code
git clone -b $BRANCH --single-branch https://github.com/ProtonMail/proton-bridge.git
cd proton-bridge
git checkout $BRANCH

#FROM https://github.com/ProtonMail/proton-bridge/pull/270#issuecomment-1365037080
sed -i 's/127.0.0.1/0.0.0.0/g' internal/constants/constants.go

# Build
make build-nogui
