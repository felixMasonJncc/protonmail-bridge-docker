# ProtonMail IMAP/SMTP Bridge Docker Container

![current version](https://img.shields.io/docker/v/ganeshlab/protonmail-bridge/latest?style=for-the-badge)  ![downloads](https://img.shields.io/docker/pulls/ganeshlab/protonmail-bridge?style=for-the-badge)

This is an unofficial Docker container of the [ProtonMail Bridge](https://github.com/ProtonMail/proton-bridge) built from source. Some of the scripts are based on [Hendrik Meyer's work](https://gitlab.com/T4cC0re/protonmail-bridge-docker). Fork of [shenxn's work](https://github.com/shenxn/protonmail-bridge-docker), all credit to them.

Docker Hub: [https://hub.docker.com/r/ganeshlab/protonmail-bridge](https://hub.docker.com/r/ganeshlab/protonmail-bridge)

GitHub: [https://github.com/ganeshlab/protonmail-bridge-docker](https://github.com/ganeshlab/protonmail-bridge-docker)

## Tags

tag | description
 -- | --
`latest` | latest `master branch` stable image
`dev` | latest `master branch` pre-release image

## Initialization

To initialize and add account to the bridge, run the following command.

```
docker run --rm -it -v /path/to/data:/root ganeshlab/protonmail-bridge init
```

Wait for the bridge to startup, use `login` command and follow the instructions to add your account into the bridge. Then use `info` to see the configuration information (username and password). After that, use `exit` to exit the bridge. You may need `CTRL+C` to exit the docker entirely.

## Run

To run the container, use one of the following examples:

## docker
```
docker run -d --name=protonmail-bridge -v /path/to/data:/root -p 1025:1025/tcp -p 1143:1143/tcp --restart=unless-stopped ganeshlab/protonmail-bridge
```

## docker-compose

```yaml
version: "3"
services:
  protonbridge:
    image: ganeshlab/protonmail-bridge:latest
    container_name: protonmail-bridge
    restart: unless-stopped
    volumes:
      - '/path/to/data:/root'
    ports:
      - '1025:1025/tcp'
      - '1143:1143/tcp'        
```

## Security

Please be aware that running the command above will expose your bridge to the network. Remember to use firewall if you are going to run this in an untrusted network or on a machine that has public IP address. You can also use the following command to publish the port to only localhost, which is the same behavior as the official bridge package.

```
docker run -d --name=protonmail-bridge -v /path/to/data:/root -p 127.0.0.1:1025:1025/tcp -p 127.0.0.1:1143:1143/tcp --restart=unless-stopped ganeshlab/protonmail-bridge
```

Besides, you can publish only port 25 (SMTP) if you don't need to receive any email (e.g. as a email notification service).

## Compatibility

The bridge currently only supports some of the email clients. More details can be found on the official website. I've tested this on a Synology DiskStation and it runs well. However, you may need ssh onto it to run the interactive docker command to add your account. The main reason of using this instead of environment variables is that it seems to be the best way to support two-factor authentication.

## Bridge CLI Guide

The initialization step exposes the bridge CLI so you can do things like switch between combined and split mode, change proxy, etc. The [official guide](https://protonmail.com/support/knowledge-base/bridge-cli-guide/) gives more information on to use the CLI.

## Build

For anyone who want to build this container on your own (for development or security concerns), here is the guide to do so. 
```
docker build .
```

That's it. The `Dockerfile` and bash scripts handle all the downloading, building, and packing. You can also add tags, push to your favorite docker registry, or use `buildx` to build multi architecture images.
