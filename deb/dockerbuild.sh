#!/bin/bash
pre=$(curl -sL https://api.github.com/repos/ProtonMail/proton-bridge/releases | jq -r '.[0] | .prerelease')
if [ "$pre" = "false" ]; then
 getver=$(curl -sL https://api.github.com/repos/ProtonMail/proton-bridge/releases | jq -r '.[0] | .tag_name')
 ver="${getver//v}"
 echo "$ver"-1 > VERSION
 docker build --no-cache -t ganeshlab/protonbridge:$ver .
else
 getver=$(curl -sL https://api.github.com/repos/ProtonMail/proton-bridge/releases | jq -r '.[0] | .tag_name')
 ver="${getver//v}"
 echo "$ver"-1 > VERSION
 docker build --no-cache -t ganeshlab/protonbridge:$ver-dev .
fi
