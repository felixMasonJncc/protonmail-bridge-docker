for running
docker run -d --name=protonmail-bridge -v /home/felix/pm-test:/root -p 1025:1025/tcp -p 1143:1143/tcp protonmail-bridge-container

for testing
docker run --name=protonmail-bridge --rm -it -v /home/felix/pm-test:/root -p 1025:1025/tcp -p 1143:1143/tcp --entrypoint=/bin/bash protonmail-bridge-container