

## Edgex Docker Compose Builder for Hanoi Release

This folder contains the `Compose Builder` which is made up of **source** compose and environment files and **makefile** for building the single file docker composes files for the configured for the `Hanoi` release. 

**Note to Developers**: 
For `Hanoi` patch release, once you have edited and tested your changes to the source compose files you **MUST** regenerate the committed `Hanoi` compose files using the `make build` command.

### Generating Custom Compose files

If one of the standard committed `Hanoi` compose files doesn't meet your needs, you can generate and run a custom `Hanoi` compose file using the `make gen <options>` command. See [Gen](#gen) and [Run](#run) target details below. `Run` simply runs the custom compose file after generating it.

### Multiple Compose files approach

The approach used with these source compose files is the `Extending using multiple Compose files` described here: https://docs.docker.com/compose/extends/#multiple-compose-files


The `Extending using multiple Compose files` approach along with environment files removes the all of the duplication found in previous EdgeX compose files. This approach makes running the solution more complicated due to having to list the multiple compose files required to run a particular configuration. To alleviate this complexity we are providing the generated single file compose files one level up and a `Makefile` has been provided here with commands that make it easy to run the multiple possible configurations while testing your changes. See the Makefile section below for details on these commands.

> *Note: The `make run`, `make pull` and `make gen` commands all generate a single `docker-compose.yml` file containing the content from the multiple compose files, environment files with all variables resolved for the specified options used. See below for list of options.*

### Compose Files

This folder contains the following compose files:

- **docker-compose-base.yml**
    Base non-secure mode compose file. Contains all the services that run in the non-secure configuration.  
- **add-security.yml**
    Security **extending** compose file. Adds the additional security services and configuration of services so that all the services are running in the secure configuration.
- **add-device-bacnet.yml**
    Device Service **extending** compose file, which adds the **Device Bacnet**  service.
- **add-device-camera.yml**
    Device Service **extending** compose file, which adds the **Device Camera**  service.
- **add-device-grove.yml**
    Device Service **extending** compose file, which adds the **Device Grove**  service.
- **add-device-modbus.yml**
    Device Service **extending** compose file, which adds the **Device Modbus**  service.
- **add-device-mqtt.yml**
    Device Service **extending** compose file, which adds the **Device MQTT**  service.
- **add-device-random.yml**
    Device Service **extending** compose file, which adds the **Device Random**  service.
- **add-device-rest.yml**
    Device Service **extending** compose file, which adds the **Device REST** service.
- **add-device-snmp.yml**
    Device Service **extending** compose file, which adds the **Device SNMP**  service.
- **add-device-virtual.yml**
    Device Service **extending** compose file, which adds the **Device Virtual**  service.
- **add-asc-http-export.yml**
    Application Service Configurable **extending** compose file, which adds the **App Service Http Export**  service.
- **add-asc-mqtt-export.yml**
    Application Service Configurable **extending** compose file, which adds the **App Service MQTT Export**  service.
- **add-modbus-simulator.yml**
    ModBus Simulator **extending** compose file. Adds the MQTT ModBus Simulator service. Must be used in conjunction with  **add-device-modbus.yml**
- **add-mqtt-broker.yml**
    MQTT Broker **extending** compose file. Adds the Eclipse Mosquitto MQTT Broker.
- **add-mqtt-messagebus.yml**
    MQTT **extending** compose file. Adds a MQTT Broker and additional configuration of services so that the `MQTT` implementation of the Edgex Message Bus is used.
- **docker-compose-ui.yml**
    Stand-alone compose file for running the optional EdgeX UI. Runs in `host` network mode and only supports connecting to local Edgex services via 127.0.0.1 IP address.

### Environment Files

This folder contains the following environment files:

- **.env**
    This file contains the release `version` (`hanoi`), `repositories` and image `version` variables referenced in compose files. Docker compose implicitly uses the `.env` file, if it exists, so you will not see it referenced in the compose files. It is referenced in the Makefile so that it can also use these settings.
- **common.env**
    This file contains the common environment overrides used by all Edgex services.
- **common-security.env**
    This file contains the common security related environment overrides used by many Edgex services.

### Makefile

This folder contains a `Makefile` that provides commands for building,  generating,  running, stopping and cleaning the various EdgeX `Hanoi` release configurations.

```
Usage: make <target> where target is:
```
#### Portainer

```
portainer       Runs Portainer independent of the EdgeX services
portainer-down	Stops Portainer independent of the EdgeX services
```
#### Build

```
build
Generates the all standard Edgex compose file variations and stores them in the configured relese folder. Each variation, except UI, includes Device REST & Device Virtual. Compose files are named appropriatly for release and options used to generate them.

Current variations are:
   full secure 
   full secure for arm64
   non-secure
   nonsecure for arm64
   stand-alone UI
   stand-alone UI for arm64
```

#### Compose

```
compose [options] 
Generates the EdgeX compose file as specified by options and stores them in the configured relese folder. Compose files are named appropriatly for release and options used to generate them.

Options:
    no-secty:    Generates non-secure compose file, otherwise generates secure compose file
    arm64:       Generates compose file using ARM64 images
    dev:         Generates compose file using local dev built images from edgex-go repo's 
                 'make docker' which creates docker images tagged with '0.0.0-dev'    
    ds-bacnet:   Generates compose file with device-bacnet included
    ds-camera:   Generates compose file with device-camera included
    ds-grove:    Generates compose file with device-grove included (valid only with arm64 option)
    ds-modbus:   Generates compose file with device-modbus included
    ds-mqtt:     Generates compose file with device-mqtt included
    ds-random:   Generates compose file with device-random included
    ds-rest:     Generates compose file with device-rest included
    ds-snmp:     Generates compose file with device-snmp included
    ds-virtual:  Generates compose file with device-virtual included
    modbus-sim:  Generates compose file with ModBus simulator included
    asc-http:    Generates compose file with App Service HTTP Export included
    asc-mqtt:    Generates compose file with App Service MQTT Export included
    mqtt-broker: Generates compose file with a MQTT Broker service included 
    mqtt-bus:    Generates compose file with services configure for MQTT Message Bus 
                 The MQTT Broker service is also included. 
    ui:          Generates stand-alone compose file for EdgeX UI	
```

#### Run

```
run [options] [services]
Runs the EdgeX services as specified by:
Options:
    no-secty:    Runs in Non-Secure Mode, otherwise runs in Secure Mode
    arm64:       Runs using ARM64 images    
    dev:         Runs using local dev built images from edgex-go repo's    
                 'make docker' which creates docker images tagged with '0.0.0-dev'
    ds-modbus:   Runs with device-modbus included
    ds-bacnet:   Runs with device-bacnet included
    ds-camera:   Runs with device-camera included
    ds-grove:    Runs with device-grove included (valid only with arm64 option)
    ds-mqtt:     Runs with device-mqtt included
    ds-random:   Runs with device-random included
    ds-rest:     Runs with device-rest included
    ds-snmp:     Runs with device-snmp included
    ds-virtual:  Runs device-virtual included
    modbus-sim:  Runs with ModBus simulator included
    asc-http:    Runs with App Service HTTP Export included
    asc-mqtt:    Runs with App Service MQTT Export included
    mqtt-broker: Runs with a MQTT Broker service included 
    mqtt-bus:    Runs with services configure for MQTT Message Bus 
    ui:          Runs only the EdgeX UI service. `ds-x`, 'mqtt', 'no-ds' & 'no-secty' are ignored. Typically used after the other Edgex Services have been started
Services:
    <names...>: Runs only services listed (and their dependent services) where 'name' matches a service name in one of the compose files used
```
#### Pull

```				
pull [options] [services]
Pulls the EdgeX service images as specified by:
Options:
    no-secty:    Pulls images for Non-Secure Mode, otherwise pull images for Secure Mode
    arm64:       Pulls ARM64 version of images    
    ds-bacnet:   Pull includes device-bacnet 
    ds-camera:   Pull includes device-camera
    ds-grove:    Pull includes device-grove (valid only with arm64 option)
    ds-modbus:   Pull includes device-modbus 
    ds-mqtt:     Pull includes device-mqtt
    ds-random:   Pull includes device-random
    ds-rest:     Pull includes device-rest
    ds-snmp:     Pull includes device-snmp
    ds-virtual:  Pull includes device-virtual
    modbus-sim:  Pull includes ModBus simulator
    asc-http:    Pull includes App Service HTTP Export
    asc-mqtt:    Pull includes App Service MQTT Export
    mqtt-broker: Pull includes MQTT Broker service
    mqtt-bus:    Pull includes additional service for MQTT Message Bus
    ui:          Pulls only the EdgeX UI service image. `ds-x`, 'mqtt', 'no-ds' & 'no-secty' are ignored
Services:
    <names...>: Pulls only images for the service(s) listed
```
#### Gen

```	
gen [options]
Generates temporary single file compose file (`docker-compose.yml`) as specified by:
Options:
    no-secty:    Generates non-secure compose, otherwise generates secure compose file
    arm64:       Generates compose file using ARM64 images    
    dev:         Generates compose file using local dev built images from edgex-go repo's 
                 'make docker' which creates docker images tagged with '0.0.0-dev'
    ds-modbus:   Generates compose file with device-modbus included
    ds-bacnet:   Generates compose file with device-bacnet included
    ds-camera:   Generates compose file with device-camera included
    ds-grove:    Generates compose file with device-grove included (valid only with arm64 option)
    ds-mqtt:     Generates compose file with device-mqtt included
    ds-random:   Generates compose file with device-random included
    ds-rest:     Generates compose file with device-rest included
    ds-snmp:     Generates compose file with device-snmp included
    ds-virtual:  Generates compose file with device-virtual included
    modbus-sim:  Generates compose file with ModBus simulator included
    asc-http:    Generates compose file with App Service HTTP Export included
    asc-mqtt:    Generates compose file with App Service MQTT Export included
    mqtt-broker: Generates compose file with a MQTT Broker service included 
    mqtt-bus:    Generates compose file with services configure for MQTT Message Bus 
                 The MQTT Broker service is also included. 
    ui:          Generates stand-alone compose file for EdgeX UI
```
#### Get-Token

```
get-token [options] 
Generates a Kong access token as specified by:
Options:
    arm64:  Generates a Kong access token using ARM64 image
    dev:    Generates a Kong access token using local dev built docker image
            'make docker', which creates docker images tagged with '0.0.0-dev'    
```
#### Ui-Down

```
ui-down 
Stops the optional EdgeX UI service
```

#### Down

```    
down
Stops all EdgeX services no matter which configuration started them
```
#### Clean

```
clean
Runs 'down' , then removes any stopped containers and then prunes unused volumes and networks
```
