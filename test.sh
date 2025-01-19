#!/bin/bash
LATEST_RELEASE=$(curl -sL https://api.github.com/repos/ProtonMail/proton-bridge/releases | 
    jq  'first(.[] | select(.prerelease==false))')
PACKAGE_ASSET=$(echo $LATEST_RELEASE | jq '.assets[] | select(.content_type=="application/x-debian-package")')
PACKAGE_SIG_ASSET=$(echo $LATEST_RELEASE | jq --arg pkg "$(echo $PACKAGE_ASSET | jq -r '.name')" '.assets[] | select(.name==($pkg + ".sig"))')

curl -L $(echo $PACKAGE_ASSET | jq -r '.browser_download_url') -o proton-bridge.deb
curl -L $(echo $PACKAGE_SIG_ASSET | jq -r '.browser_download_url') -o proton-bridge.deb.sig
