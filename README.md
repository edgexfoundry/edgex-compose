## Hanoi Release compose files

This branch contains the docker compose files that pull and run the EdgeX Hanoi release images. 

These compose files are auto generated from the multiple files contained in the `compose-builder` folder. See [README](../../../compose-builder/README.md) there for details.

### Compose Files

This folder contains the following compose files:

#### Generated Compose files

> **NOTES: Developers **
>
> - *DO NOT EDIT the files directly for permanent changes. Make all permanent changes to the source compose files in the `compose-builder` folder and then regenerate these files*
> - Use `make build` to regenerate all the following compose files.
> - See each description for the convenience `make` commands that are provided to work with these compose files.

- **docker-compose-hanoi.yml**
    Contains all the services required to run in secure configuration. 
    **Make Commands** 
    
     - Use `make run <service(s)>` and `make down` to start and stop the services using this compose file.
    
     - Use `make pull <service(s)>` to pull all or some images for the services in this compose file.
    
     - Use `make get-token` to generate a Kong access token for remote access of the services running from this compose file.
    
- **docker-compose-hanoi-arm64.yml**
    Contains all the services required to run in secure configuration on `ARM64` system. 
    **Make Commands** 
    
     - Use `make run arm64` and `make down` to start and stop the services using this compose file.
     - Use `make pull arm64 <service(s)>` to pull all or some images for the services in this compose file.
     - Use `make get-token arm64` to generate a Kong access token for remote access of the services running from this compose file.
    
- **docker-compose-hanoi-no-secty.yml**
    Contains just the services needed to run in non-secure configuration. 
    **Make Commands**

    - Use `make run no-secty` and `make down` to start and stop the services using this compose file.
    - Use `make pull no-secty <service(s)>` to pull all or some images for the services in this compose file.
    
- **docker-compose-hanoi-no-secty-arm64.yml**
    Contains just the services needed to run in non-secure configuration on `ARM64` system. 
    
    **Make Commands**
    
    - Use `make run no-secty arm64` and `make down` to start and stop the services using this compose file.
    - Use `make pull no-secty arm64 <service(s)>` to pull all or some images for the services in this compose file.
    
- **docker-compose-hanoi-ui.yml**
    Stand-alone compose file for running the optional EdgeX UI.
    **Make Commands**
    
    - Use `make run-ui` and `make down-ui` to start and stop the UI using this compose file.
    - Use `make pull-ui ` to pull image for the UI service in this compose file.
    
- **docker-compose-hanoi-ui-arm64.yml**
    Stand-alone compose file for running the optional EdgeX UI on `ARM64` system.
    
    **Make Commands**
    
    - Use `make run-ui arm64` and `make down-ui arm64` to start and stop the UI using this compose file.
    - Use `make pull-ui arm64`  to pull image for the UI service in this compose file.

### Additional compose files

- **docker-compose-portainer.yml**
    Stand-alone compose file for running Portainer which is a  Docker container management tool. Visit here https://www.portainer.io/ for more details on Portianer.
    Use `make portainer`and `make portainer-down` to start and stop Portainer.

### Additional make commands

- `make clean`

  Runs `down` commands, removes all stopped container and prunes all unused volumes and networks. Use this command when needing to do a fresh restart.

- `make get-token`

  Generates a Kong access token for previously started secure stack. Must provide the `arm64` option if running on ARM64
