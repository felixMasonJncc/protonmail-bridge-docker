#!/bin/bash

PROTONMAIL_RELEASE_API_URL=$1

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

get_public_key_asset() {
    local release="$1"
    echo "$release" | jq '.assets[] | select(.name=="bridge_pubkey.gpg")'
}

download_asset() {
    local url="$1"
    local name="$2"
    curl -L "$url" -o "$name"
}

main() {
    local latest_release
    local package_asset
    local package_name
    local package_sig_asset
    local public_key_asset
    local bridge_version
    local bridge_release_name

    latest_release=$(get_latest_stable_release)
    [ -z "$latest_release" ] && { echo "Failed to fetch release information"; exit 1; }

    bridge_version=$(echo "$latest_release" | jq -r '.tag_name')
    bridge_release_name=$(echo "$latest_release" | jq -r '.name')

    package_asset=$(get_package_asset "$latest_release")
    [ -z "$package_asset" ] && { echo "Failed to find package asset"; exit 1; }

    package_name=$(echo "$package_asset" | jq -r '.name')
    package_sig_asset=$(get_package_signature "$latest_release" "$package_name")

    public_key_asset=$(get_public_key_asset "$latest_release")

    $(download_asset "$(echo "$package_asset" | jq -r '.browser_download_url')" "$package_name")
    $(download_asset "$(echo "$package_sig_asset" | jq -r '.browser_download_url')" "$package_name.sig")
    $(download_asset "$(echo "$public_key_asset" | jq -r '.browser_download_url')" bridge_pubkey.gpg)

    if [ ! -f "$package_name" ]; then
        echo "Failed to download package"
        exit 1
    fi

    echo "Package downloaded successfully"

    if [ ! -f "$package_name.sig" ]; then
        echo "Failed to download package signature"
        exit 1
    fi

    echo "Package signature downloaded successfully"

    if [ ! -f "bridge_pubkey.gpg" ]; then
        echo "Failed to download public key"
        exit 1
    fi
    
    echo "Public key downloaded successfully"

    # install public key
    gpg --import bridge_pubkey.gpg

    # check package using signature
    if ! gpg --verify "$package_name.sig" "$package_name"; then
        echo "Package signature verification failed"
        exit 1
    fi
    echo "Package signature verified successfully - check 1"

    # check package against protonmail public key
    if ! debsig-verify "$package_name"; then
        echo "Package signature verification failed"
        exit 1
    fi

    echo "Package signature verified successfully - check 2"

    mkdir validated
    mv "$package_name" validated/protonmail-bridge.deb

    echo "Moved package to output dir"

}

main
