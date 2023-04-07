#!/bin/bash
pre=$(curl -sL https://api.github.com/repos/ProtonMail/proton-bridge/releases | jq -r '.[0] | .prerelease')
getver=$(curl -sL https://api.github.com/repos/ProtonMail/proton-bridge/releases | jq -r '.[0] | .tag_name')
ver="${getver//v}"
echo "$ver"-1 > VERSION
if [ "$pre" = "false" ]; then
 docker build --no-cache -t ganeshlab/protonmail-bridge:$ver .
else
 docker build --no-cache -t ganeshlab/protonmail-bridge:$ver-dev .
fi
