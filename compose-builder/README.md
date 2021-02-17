## Edgex Docker Compose Builder

This folder contains the `Compose Builder` which is made up of **source** compose and environment files and **makefile** for building the single file docker composes files for the configured `release`. The default release is `pre-release` and the generated compose files are placed in `releases/pre-release/compose-files`. 

> **Note to Developers**: 
> *Once you have edited and tested your changes to these source files you **MUST** regenerate the composes using the `make build` command.*

### Generate next release compose files

Do the following to build compose files for next release such as `hanoi` 

1. Update the `RELEASE`, `REPOSITORY`, `CORE_EDGEX_REPOSITORY`, `APP_SVC_REPOSITORY`, and `versions` contained in the `.env` file.
2. Create the release folder, i.e `release/hanoi/compose-files`
3. Run `make build` 
4. Commit changes, open PR and merge PR
5. TAG repo for new release, i.e. `1.3.0`
   - This is need for generating dot releases and allows user to get back to the `release` source compose and .env files so they can generate custom compose files base on the `release`.  
6. **Undo changes made to `.env` file**. (values on master branch **must** remain as `nexus/nightly-build`)
7. Commit changes, open PR and merge PR

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
- **add-asc-http-export-secure.yml**
    Application Service Configurable **extending** compose file, which adds the **App Service Http Export Secrets** service. Service is enable for secure secrets.
- **add-asc-mqtt-export.yml**
    Application Service Configurable **extending** compose file, which adds the **App Service MQTT Export**  service.
- **add-asc-mqtt-export-secure.yml**
    Application Service Configurable **extending** compose file, which adds the **App Service MQTT Export Secrets** service. Service is enable for secure secrets.
- **add-modbus-simulator.yml**
    ModBus Simulator **extending** compose file. Adds the MQTT ModBus Simulator service. Must be used in conjunction with  **add-device-modbus.yml**
- **add-mqtt-broker.yml**
    MQTT Broker **extending** compose file. Adds the Eclipse Mosquitto MQTT Broker.
- **add-mqtt-messagebus.yml**
    MQTT MesssageBus **extending** compose file. Adds additional configuration of services so that the `MQTT` implementation of the Edgex Message Bus is used. **Must be used in conjunction with add-mqtt-broker.yml**
- **add-taf-app-services.yml**
    TAF App Services **extending** compose file. Adds additional App Service for the TAF testing compose files.
- **add-taf-device-services-mods.yml**
    TAF Device Services **extending** compose file. Modifies setting of Device Virtual and Device Modbus for the TAF testing compose files. **Must be used in conjunction with add-device-modbus.yml and add-device-virtual.yml**
- **docker-compose-ui.yml**
    Stand-alone compose file for running the optional EdgeX UI. Runs in `host` network mode and only supports connecting to local Edgex services via 127.0.0.1 IP address.

### Environment Files

This folder contains the following environment files:

- **.env**
    This file contains the `version`, `repositories` and image `version` variables referenced in compose files. Docker compose implicitly uses the `.env` file, if it exists, so you will not see it referenced in the compose files. It is referenced in the Makefile so that it can also use these settings.
- **common.env**
    This file contains the common environment overrides used by all Edgex services.
- **common-security.env**
    This file contains the common security related environment overrides used by many Edgex services.
- **common-sec-stage-gate.env**
    This file contains the common security-bootstrapper stage gate related environment overrides used by many Edgex services.

### Makefile

This folder contains a `Makefile` that provides commands for running, stopping and cleaning the various EdgeX configurations during **development** of the compose files or testing edgex-go's dev version by `dev` argument
and/or app-service-configurable's dev version by `app-dev` argument for the service images.

```
Usage: make <target> where target is:
```
```
portainer       Runs Portainer independent of the EdgeX services
portainer-down	Stops Portainer independent of the EdgeX services
```
```
build
Generates the all standard Edgex compose file variations and the TAF testing compose files. The generated compose files are stored in the configured release folder. Each variation or standard compose files, except UI, includes Device REST & Device Virtual. Compose files are named appropriately for release and options used to generate them. TAF compose files are store in the 'taf' sub-folder

Standard compose variations are:
   full secure (docker-compose-nexus.yml)
   full secure for arm64 (docker-compose-nexus-arm64.yml)
   non-secure (docker-compose-nexus-no-secty.yml)
   nonsecure for arm64 (docker-compose-nexus-no-secty-arm64.yml)
   stand-alone UI (docker-compose-nexus-ui.yml)
   stand-alone UI for arm64 (docker-compose-nexus-ui-arm64.yml)
   
 TAF compose variations are:
   full secure general testing (docker-compose-taf-nexus.yml)
   full secure general testing for arm64 (docker-compose-taf-nexus-arm64.yml)
   non-secure general testing (docker-compose-nexus-taf-no-secty.yml)
   nonsecure general testing for arm64 (docker-compose-taf-nexus-no-secty-arm64.yml)
   full secure perf testing (docker-compose-taf-perf-nexus.yml)
   full secure perf testing for arm64 (docker-compose-taf-perf-nexus-arm64.yml)
   non-secure perf testing (docker-compose-nexus-taf-perf-no-secty.yml)
   nonsecure perf testing for arm64 (docker-compose-taf-perf-nexus-no-secty-arm64.yml)
```
```
compose [options] 
Generates the EdgeX compose file as specified by options and stores them in the configured release folder. Compose files are named appropriatly for release and options used to generate them.

Options:
    no-secty:   Generates non-secure compose file, otherwise generates secure compose file
    arm64:      Generates compose file using ARM64 images
    dev:        Generates compose file using local dev built images from edgex-go repo's 
                'make docker' which creates docker images tagged with '0.0.0-dev'    
    app-dev:    Generates compose file using local dev built images from app-service-configurable repo's
                'make docker' which creates docker images tagged with 'master-dev'
    ds-bacnet:  Generates compose file with device-bacnet included
    ds-camera:  Generates compose file with device-camera included
    ds-grove:   Generates compose file with device-grove included (valid only with arm64 option)
    ds-modbus:   Generates compose file with device-modbus included
    ds-mqtt:     Generates compose file with device-mqtt included
    ds-random:   Generates compose file with device-random included
    ds-rest:     Generates compose file with device-rest included
    ds-snmp:     Generates compose file with device-snmp included
    ds-virtual:  Generates compose file with device-virtual included
    modbus-sim:  Generates compose file with ModBus simulator included
    asc-http:    Generates compose file with App Service HTTP Export included
    asc-http-s:  Generates compose file with App Service HTTP Export Secrets included
    asc-mqtt:    Generates compose file with App Service MQTT Export included
    asc-mqtt-s:  Generates compose file with App Service MQTT Export Secrets included
    mqtt-broker: Generates compose file with a MQTT Broker service included 
    mqtt-bus:    Generates compose file with services configure for MQTT Message Bus 
                 The MQTT Broker service is also included. 
    ui:          Generates stand-alone compose file for EdgeX UI	
```
```
taf-compose [options] 
Generates a TAF general testing compose file as specified by options and stores them in the configured TAF release folder. Compose files are named appropriately for the options used to generate them.

Options:
    taf-secty:	  Generates general TAF testing compose file with security services
    taf-no-secty: Generates general TAF testing compose file without security services
    arm64:        Generates TAF compose file using ARM64 images
```
```
taf-perf-compose [options] 
Generates a TAF performance testing compose file as specified by options and stores them in the configured TAF release folder. Compose files are named appropriately for the options used to generate them.

Options:
    taf-secty:	  Generates performance TAF testing compose file with security services
    taf-no-secty: Generates performance TAF testing compose file without security services
    arm64:        Generates TAF compose file using ARM64 images
```
```
run [options] [services]
Runs the EdgeX services as specified by:
Options:
    no-secty:    Runs in Non-Secure Mode, otherwise runs in Secure Mode
    arm64:       Runs using ARM64 images    
    dev:         Runs using local dev built images from edgex-go repo's    
                 'make docker' which creates docker images tagged with '0.0.0-dev'
    app-dev:     Runs using local dev built images from app-service-configurable repo's
                 'make docker' which creates docker images tagged with 'master-dev'
    ds-modbus:   Runs with device-modbus included
    ds-bacnet:   Runs with device-bacnet included
    ds-camera:   Runs with device-camera included
    ds-grove:    Runs with device-grove included (valid only with arm64 option)
    ds-mqtt:     Runs with device-mqtt included
    ds-random:   Runs with device-random included
    ds-rest:     Runs with device-rest included
    ds-snmp:     Runs with device-snmp included
    ds-virtual:  Runs with device-virtual included
    modbus-sim:  Runs with ModBus simulator included
    asc-http:    Runs with App Service HTTP Export included
    asc-http-s:  Runs with App Service HTTP Export Secrets included
    asc-mqtt:    Runs with App Service MQTT Export included
    asc-mqtt-s:  Runs with App Service MQTT Export Secrets included
    mqtt-broker: Runs with a MQTT Broker service included 
    mqtt-bus:    Runs with services configure for MQTT Message Bus 
    ui:          Runs only the EdgeX UI service. `ds-x`, 'mqtt', 'no-ds' & 'no-secty' are ignored. Typically used after the other Edgex Services have been started
Services:
    <names...>: Runs only services listed (and their dependent services) where 'name' matches a service name in one of the compose files used
```
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
    asc-http-s:  Pull includes App Service HTTP Export Secrets
    asc-mqtt:    Pull includes App Service MQTT Export
    asc-mqtt-s:  Pull includes App Service MQTT Export Secrets
    mqtt-broker: Pull includes MQTT Broker service
    mqtt-bus:    Pull includes additional service for MQTT Message Bus
    ui:          Pulls only the EdgeX UI service image. `ds-x`, 'mqtt', 'no-ds' & 'no-secty' are ignored
Services:
    <names...>: Pulls only images for the service(s) listed
```
```	
gen [options]
Generates temporary single file compose file (`docker-compose.yml`) as specified by:
Options:
    no-secty:   Generates non-secure compose, otherwise generates secure compose file
    arm64:      Generates compose file using ARM64 images    
    dev:        Generates compose file using local dev built images from edgex-go repo's 
                'make docker' which creates docker images tagged with '0.0.0-dev'
    app-dev:    Generates compose file using local dev built images from app-service-configurable repo's
                'make docker' which creates docker images tagged with 'master-dev'
    ds-modbus:  Generates compose file with device-modbus included
    ds-bacnet:  Generates compose file with device-bacnet included
    ds-camera:  Generates compose file with device-camera included
    ds-grove:   Generates compose file with device-grove included (valid only with arm64 option)
    ds-mqtt:     Generates compose file with device-mqtt included
    ds-random:   Generates compose file with device-random included
    ds-rest:     Generates compose file with device-rest included
    ds-snmp:     Generates compose file with device-snmp included
    ds-virtual:  Generates compose file with device-virtual included
    modbus-sim:  Generates compose file with ModBus simulator included
    asc-http:    Generates compose file with App Service HTTP Export included
    asc-http-s:  Generates compose file with App Service HTTP Export Secrets included
    asc-mqtt:    Generates compose file with App Service MQTT Export included
    asc-mqtt-s:  Generates compose file with App Service MQTT Export Secrets included
    mqtt-broker: Generates compose file with a MQTT Broker service included 
    mqtt-bus:    Generates compose file with services configure for MQTT Message Bus 
                 The MQTT Broker service is also included. 
    ui:          Generates stand-alone compose file for EdgeX UI
```
```
get-token [options] 
Generates a Kong access token as specified by:
Options:
    arm64:  Generates a Kong access token using ARM64 image
    dev:    Generates a Kong access token using local dev built docker image
            'make docker', which creates docker images tagged with '0.0.0-dev'    
```
```
upload-tls-cert [options] <environment_variables>
Upload a bring-your-own (BYO) TLS certificate to the Kong proxy server as specified by:
Options:
    arm64:  Upload TLS certificate to the Kong server using ARM64 image
    dev:    Upload TLS certificate to the Kong server using local dev built docker image
            'make docker', which creates docker images tagged with '0.0.0-dev'
Environment Variables: 
    CERT_INPUT_FILE=<full_path_to_cert_file>: the full file name path to your own certificate file, this is required
    KEY_INPUT_FILE=<full_path_to_key_file>: the full file name path to your own key file, this is required
    EXTRA_SNIS="comma_separated_server_name_list_if_any": an extra server name indicator list in addition to localhost and kong, this is optional and can be omitted
```

```
ui-down 
Stops the optional EdgeX UI service
```

```    
down
Stops all EdgeX services no matter which configuration started them
```
```
clean
Runs 'down' , then removes any stopped containers and then prunes unused volumes and networks
```
