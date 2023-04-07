#!/bin/bash
PRE=$(curl -sL https://api.github.com/repos/ProtonMail/proton-bridge/releases | jq -r '.[0] | .prerelease')
GETVER=$(curl -sL https://api.github.com/repos/ProtonMail/proton-bridge/releases | jq -r '.[0] | .tag_name')
VER="${GETVER//v}"
ARCH="$(uname -m)"
if [[ $ARCH == "aarch64" ]] ; then
  TAG="arm64v8"
else
  TAG="amd64"
fi
if [ "$PRE" = "false" ]; then
 docker build --no-cache -t ganeshlab/protonmail-bridge:$VER-$TAG .
else
 docker build --no-cache -t ganeshlab/protonmail-bridge:dev-$VER-$TAG .
fi
