# Download and verify latest protonmail bridge release
FROM ubuntu:latest as verify
RUN apt-get update && apt-get install -y --no-install-recommends curl debsig-verify debian-keyring jq

# From https://proton.me/support/verifying-bridge-package
# Install the protonmail public key 
RUN curl -L "https://proton.me/download/bridge/bridge_pubkey.gpg" -o "bridge_pubkey.gpg" \
    && gpg --dearmor --output debsig.gpg bridge_pubkey.gpg \
    && mkdir -p /usr/share/debsig/keyrings/E2C75D68E6234B07 \
    && mv debsig.gpg /usr/share/debsig/keyrings/E2C75D68E6234B07

# Install the public key policy
RUN curl -L "https://proton.me/download/bridge/bridge.pol" - o "bridge.pol" \
    && mkdir -p /etc/debsig/policies/E2C75D68E6234B07 \
    && mv bridge.pol /etc/debsig/policies/E2C75D68E6234B07

WORKDIR /package-download

COPY download-protonmail.sh .
RUN ./download-protonmail.sh

# Instal proton-bridge
FROM ubuntu:latest
LABEL maintainer="felixmasonjncc"

RUN apt-get update && apt-get install -y --no-install-recommends pass libsecret-1-0 ca-certificates

WORKDIR /install

COPY --from=build /package-download/validated/protonmail-bridge.deb .
RUN apt install ./protonmail-bridge.deb

COPY entrypoint.sh /protonmail/

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]
