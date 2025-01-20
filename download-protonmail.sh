#!/bin/bash

PROTONMAIL_RELEASE_API_URL="https://api.github.com/repos/ProtonMail/proton-bridge/releases"

get_latest_stable_release() {
    curl -sL "$PROTONMAIL_RELEASE_API_URL" | jq 'first(.[] | select(.prerelease==false))'
}

get_package_asset() {
    local release="$1"
    echo "$release" | jq '.assets[] | select(.content_type=="application/x-debian-package")'
}

get_package_signature() {
    local release="$1"
    local package_name="$2"
    echo "$release" | jq --arg pkg "$package_name" '.assets[] | select(.name==($pkg + ".sig"))'
}

download_package() {
    local package_url="$1"
    local package_name="$2"
    curl -L "$package_url" -o "$package_name"
}

download_package_signature() {
    local package_sig_url="$1"
    local package_sig_name="$2"
    curl -L "$package_sig_url" -o "$package_sig_name"
}




# Main execution
main() {
    local latest_release
    local package_asset
    local package_name
    local package_sig_asset

    latest_release=$(get_latest_stable_release)
    [ -z "$latest_release" ] && { echo "Failed to fetch release information"; exit 1; }

    package_asset=$(get_package_asset "$latest_release")
    [ -z "$package_asset" ] && { echo "Failed to find package asset"; exit 1; }

    package_name=$(echo "$package_asset" | jq -r '.name')
    package_sig_asset=$(get_package_signature "$latest_release" "$package_name")

    $(download_package "$(echo "$package_asset" | jq -r '.browser_download_url')" "$package_name")
    $(download_package_signature "$(echo "$package_sig_asset" | jq -r '.browser_download_url')" "$package_name.sig")

    if [ ! -f "$package_name" ]; then
        echo "Failed to download package"
        exit 1
    fi

    if [ ! -f "$package_name.sig" ]; then
        echo "Failed to download package signature"
        exit 1
    fi

    echo "Package downloaded successfully"
    echo "Package signature downloaded successfully"

    # check package using signature
    if ! gpg --verify "$package_name.sig" "$package_name"; then
        echo "Package signature verification failed"
        exit 1
    fi
    echo "Package signature verified successfully"

    # check package against protonmail public key
    if ! debsig-verify "$package_name"; then
        echo "Package signature verification failed"
        exit 1
    fi

    echo "Package signature verified successfully"

    mkdir validated
    mv "$package_name" validated/protonmail-bridge.deb

    echo "Moved package to output dir"

}

main
