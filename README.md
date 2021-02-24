# EdgeX Compose

This repo contains the Docker compose files for deploying the EdgeX services in Docker. 

The `compose-builder` folder contains the files used to generate the compose files under the `releases/pre-release` folder and the initial compose files for new releases. See the Compose Builder [README](./compose-builder/README.md) for more details

The `releases/pre-release` folder contains the WIP (work in progress) compose files for the upcoming release and the TAF testing compose files. The folder also contains a `Makefile` with commands for running the various versions. See the pre-release [README](./releases/pre-release/README.md) for more details.

The  `releases/<name>` folders contain the compose files for the official EdgeX releases. Recent releases such as `hanoi` have generated compose files and a `Makefile` with commands for running the various versions. See the release README (where exists) for more details.

