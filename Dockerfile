FROM golang:alpine AS build

# Install dependencies
RUN apk add git libsecret-dev bash alpine-sdk

# Build
WORKDIR /build/
COPY build.sh /build/
RUN bash build.sh

FROM alpine:3
LABEL maintainer="ganeshlab"

# Install dependencies and protonmail bridge
RUN apk add pass libsecret gnupg

# Copy bash scripts
COPY gpgparams entrypoint.sh /protonmail/

# Copy protonmail
COPY --from=build /build/proton-bridge/bridge /protonmail/
COPY --from=build /build/proton-bridge/proton-bridge /protonmail/

ENTRYPOINT ["sh", "/protonmail/entrypoint.sh"]
