# Build proton-bridge
FROM golang:alpine AS build

RUN apk add --no-cache git libsecret-dev bash alpine-sdk
RUN git clone https://github.com/ProtonMail/proton-bridge.git

WORKDIR /go/proton-bridge/

# https://github.com/ProtonMail/proton-bridge/pull/270#issuecomment-1365037080
RUN sed -i 's/127.0.0.1/0.0.0.0/g' internal/constants/constants.go
RUN make build-nogui

# Production image, copy files and run
FROM alpine:3
LABEL maintainer="ganeshlab"

RUN apk add --no-cache pass libsecret gnupg

COPY --from=build /go/proton-bridge/bridge /protonmail/
COPY --from=build /go/proton-bridge/proton-bridge /protonmail/
COPY entrypoint.sh /protonmail/

ENTRYPOINT ["sh", "/protonmail/entrypoint.sh"]
