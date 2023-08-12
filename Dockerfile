# Build proton-bridge
FROM golang:bookworm AS build
RUN apt-get update && apt-get install -y --no-install-recommends git build-essential libsecret-1-dev
RUN git clone https://github.com/ProtonMail/proton-bridge.git

WORKDIR /go/proton-bridge/

# https://github.com/ProtonMail/proton-bridge/pull/270#issuecomment-1365037080
RUN sed -i 's/127.0.0.1/0.0.0.0/g' internal/constants/constants.go
RUN make build-nogui

# Production image, copy files and run
FROM debian:stable-slim
LABEL maintainer="ganeshlab"

RUN apt-get update && apt-get install -y --no-install-recommends pass libsecret-1-0 ca-certificates

COPY --from=build /go/proton-bridge/bridge /protonmail/
COPY --from=build /go/proton-bridge/proton-bridge /protonmail/
COPY entrypoint.sh /protonmail/

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]
