## Edgex Docker Compose Builder

This folder contains the `Compose Builder` which is made up of **source** compose, **environment** files and a **makefile** for building the single file docker composes files. The `master` branch builds the `pre-release`  compose files which are placed in the top level of this repository. 

> **Note to Developers**: 
> *Once you have edited and tested your changes to these source files you **MUST** regenerate the standard `pre-release` compose files using the `make build` command.*

### Generate next release compose files

Do the following to generate the compose files for next release such as `jakarta` 

1. Create the new `release` branch from this branch, i.e create the `jakarta` branch
2. Checkout a new working branch from the new `release` branch
3. Update the `REPOSITORY`, `CORE_EDGEX_REPOSITORY`, `APP_SVC_REPOSITORY`, and `versions` contained in the `.env` file appropriately for the new release
4. Run `make build` 
5. Update the two READMEs to be specific to the new `release`
6. Commit changes, open PR and merge PR
7. TAG the new release branch, i.e. `2.1.0`
8. Update EdgeX documentation to refer to the new release branch.

### Generate dot release compose files

1. Checkout a new working branch from the target `release` branch for the dot release, i.e the `ireland` branch
2. Update the and `versions` contained in the `.env` file appropriately for the dot release
3. Run `make build` 
4. Commit changes, open PR and merge PR
5. TAG the release branch for the dot release, i.e. `2.0.1`

### Multiple Compose files approach

The approach used with these source compose files is the `Extending using multiple Compose files` described here: https://docs.docker.com/compose/extends/#multiple-compose-files

The `Extending using multiple Compose files` approach along with environment files removes the all of the duplication found in earlier EdgeX compose files. This approach makes running the solution more complicated due to having to list the multiple compose files required to run a particular configuration. To alleviate this complexity we provide generated single file compose files one level up. A `Makefile` has been provided here with commands that make it easy to run one of the multiple possible configurations while testing your changes. See the Makefile section below for details on these commands.

> *Note: The `make run`, `make pull` and `make gen` commands all generate a single `docker-compose.yml` file containing the content from the multiple compose files, environment files with all variables resolved for the specified options used. See below for list of options.*

### Compose Files

This folder contains the following compose files:

- **docker-compose-base.yml**
    Base non-secure mode compose file. Contains all the services that run in the non-secure configuration.  
- **add-security.yml**
    Security **extending** compose file. Adds the additional security services and configuration of services so that all the services are running in the secure configuration.
- **add-secure-redis-messagebus.yml**
    Secure Redis MessageBus **extending** compose file. Adds the additional security configuration for when Redis is used as MessageBus in secure mode so Kuiper can connect to the secure MesssageBus.
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
- **add-device-rest.yml**
    Device Service **extending** compose file, which adds the **Device REST** service.
- **add-device-snmp.yml**
    Device Service **extending** compose file, which adds the **Device SNMP**  service.
- **add-device-virtual.yml**
    Device Service **extending** compose file, which adds the **Device Virtual**  service.
- **add-device-virtual.yml**
    Device Service **extending** compose file, which adds the **Device Virtual**  service.
- **add-device-coap.yml**
    Device Service **extending** compose file, which adds the **Device COAP** service.
- **add-device-gpio.yml**
    Device Service **extending** compose file, which adds the **Device GPIO**  service.
- **add-device-rfid-llrp.yml**
    Device Service **extending** compose file, which adds the **Device RFID LLRP**  service.
- **add-asc-http-export.yml**
    Application Service Configurable **extending** compose file, which adds the **App Service Http Export**  service.
- **add-asc-sample.yml**
    Application Service Configurable **extending** compose file, which adds the **App Service Sample**  service.
- **add-asc-mqtt-export.yml**
    Application Service Configurable **extending** compose file, which adds the **App Service MQTT Export**  service.
- **add-app-rfid-llrp-inventory.yml**
    Application Service Configurable **extending** compose file, which adds the **App RFID LLRP Inventory**  service.
- **add-service-secure-template.yml**
    A template for a single service **extending** compose file from its base service for security mode,
    and the service is enabled with secret store by default.
- **add-mqtt-messagebus-app-template.yml**
    A template for a single App service **extending** compose file from its base service for using MQTT as the MessageBus.
- **add-mqtt-messagebus-device-template.yml**
    A template for a single Device service **extending** compose file from its base service for using MQTT as the MessageBus.
- **add-modbus-simulator.yml**
    ModBus Simulator **extending** compose file. Adds the MQTT ModBus Simulator service. Must be used in conjunction with  **add-device-modbus.yml**
- **add-mqtt-broker.yml**
    MQTT Broker **extending** compose file. Adds the Eclipse Mosquitto MQTT Broker.
- **add-mqtt-messagebus.yml**
    MQTT MesssageBus **extending** compose file. Adds additional configuration of services so that the `MQTT` implementation of the Edgex Message Bus is used. **Must be used in conjunction with add-mqtt-broker.yml**
- **add-taf-app-services.yml**
    TAF App Services **extending** compose file. Adds additional App Service for the TAF testing compose files.
- **add-taf-app-services-secure.yml**
    TAF App Services **extending** `add-taf-app-services` compose file, and services are enabled with secret store by default.
- **add-taf-device-services-mods.yml**
    TAF Device Services **extending** compose file. Modifies setting of Device Virtual and Device Modbus for the TAF testing compose files. **Must be used in conjunction with add-device-modbus.yml and add-device-virtual.yml**
- **add-ui.yml**
    UI **extending** compose file, which adds the **Edgex UI** service. 

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
- **asc-common.env**
    This file contains the common environment overrides used by all Application Services
- **asc-http-export.env**
    This file contains the common environment overrides used by all App Service Configurable instances using the `http-export` profile
- **asc-mqtt-export.env**
- This file contains the common environment overrides used by all App Service Configurable instances using the `mqtt-export` profile

### Makefile

This folder contains a `Makefile` that provides commands for building, running, stopping,  generating, cleaning, etc. for the various EdgeX configurations. It is used during **development** of the compose files or generating DEV version for testing service changes.  See the [Gen](#gen) command below for more details on options available to use when generating compose files.

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
Generates the all standard Edgex compose file variations and the TAF testing compose files. The generated compose files are stored in the top level folder. Each variation of standard compose files includes the Device REST & Device Virtual . Compose files are named appropriately for options used to generate them. TAF compose files are store in the 'taf' sub-folder

Standard compose variations are:
   full secure (docker-compose.yml)
   full secure for arm64 (docker-compose-arm64.yml)
   non-secure (docker-compose-no-secty.yml)
   non-secure for arm64 (docker-compose-no-secty-arm64.yml)
   non-secure with UI (docker-compose-no-secty-with-ui.yml)
   non-secure with UI for arm64 (docker-compose-no-secty-with-ui-arm64.yml)

 TAF compose variations are:
   full secure general testing (docker-compose-taf.yml)
   full secure general testing for arm64 (docker-compose-taf-arm64.yml)
   non-secure general testing (docker-compose-taf-no-secty.yml)
   nonsecure general testing for arm64 (docker-compose-taf-no-secty-arm64.yml)
   full secure perf testing (docker-compose-taf-perf.yml)
   full secure perf testing for arm64 (docker-compose-taf-perf-arm64.yml)
   non-secure perf testing (docker-compose-taf-perf-no-secty.yml)
   nonsecure perf testing for arm64 (docker-compose-taf-perf-no-secty-arm64.yml)
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
    app-dev:     Runs using local dev built images from app-service-configurable repo's
                 'make docker' which creates docker images tagged with '0.0.0-dev'
    ds-modbus:   Runs with device-modbus included
    ds-bacnet:   Runs with device-bacnet included
    ds-camera:   Runs with device-camera included
    ds-grove:    Runs with device-grove included (valid only with arm64 option)
    ds-mqtt:     Runs with device-mqtt included
    ds-rest:     Runs with device-rest included
    ds-snmp:     Runs with device-snmp included
    ds-virtual:  Runs with device-virtual included
    ds-coap:     Runs with device-coap included
    ds-gpio:     Runs with device-gpio included
    ds-llrp:     Runs with device-rfid-llrp included
    modbus-sim:  Runs with ModBus simulator included
    asc-http:    Runs with App Service HTTP Export included
    asc-mqtt:    Runs with App Service MQTT Export included
    asc-sample:  Runs with App Service Sample included
    as-llrp:     Runs with App RFID LLRP Inventory included
    mqtt-broker: Runs with a MQTT Broker service included 
    mqtt-bus:    Runs with services configure for MQTT Message Bus 
    zmq-bus:     Runs with services configure for ZMQ Message Bus     
    ui:          Runs with the UI service included

Services:
    <names...>: Runs only services listed (and their dependent services) where 'name' matches a service name in one of the compose files used
```
#### Down

```    
down
Stops all EdgeX services no matter which configuration started them
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
    ds-rest:     Pull includes device-rest
    ds-snmp:     Pull includes device-snmp
    ds-virtual:  Pull includes device-virtual
    ds-coap:     Pull includes device-coap
    ds-gpio:     Pull includes device-gpio
    ds-llrp:     Pull includes device-rfid-llrp
    modbus-sim:  Pull includes ModBus simulator
    asc-http:    Pull includes App Service HTTP Export
    asc-mqtt:    Pull includes App Service MQTT Export
    asc-sample:  Pull includes App Service Sample
    as-llrp:     Pull includes App RFID LLRP Inventory
    mqtt-broker: Pull includes MQTT Broker service
    mqtt-bus:    Pull includes additional services for MQTT Message Bus
    zmq-bus:     Pull includes additional services for ZMQ Message Bus     
    ui:          Pulls includes the EdgeX UI service.

Services:
    <names...>: Pulls only images for the service(s) listed
```
#### Gen

```	
gen [options]
Generates temporary single file compose file (`docker-compose.yml`) as specified by:
Options:
    no-secty:   Generates non-secure compose, otherwise generates secure compose file
    arm64:      Generates compose file using ARM64 images    
    dev:        Generates compose file using local dev built images from edgex-go repo's 
                'make docker' which creates docker images tagged with '0.0.0-dev'
    app-dev:    Generates compose file using local dev built images from app-service-configurable repo's
                'make docker' which creates docker images tagged with '0.0.0-dev'
    ds-modbus:  Generates compose file with device-modbus included
    ds-bacnet:  Generates compose file with device-bacnet included
    ds-camera:  Generates compose file with device-camera included
    ds-grove:   Generates compose file with device-grove included (valid only with arm64 option)
    ds-mqtt:     Generates compose file with device-mqtt included
    ds-rest:     Generates compose file with device-rest included
    ds-snmp:     Generates compose file with device-snmp included
    ds-virtual:  Generates compose file with device-virtual included
    ds-coap:     Generates compose file with device-coap included
    ds-gpio:     Generates compose file with device-gpio included
    ds-llrp:     Generates compose file with device-rfid-llrp included
    modbus-sim:  Generates compose file with ModBus simulator included
    asc-http:    Generates compose file with App Service HTTP Export included
    asc-mqtt:    Generates compose file with App Service MQTT Export included
    asc-sample:  Generates compose file with App Service Sample included
    as-llrp:     Generates compose file with App RFID LLRP Inventory included
    mqtt-broker: Generates compose file with a MQTT Broker service included 
    mqtt-bus:    Generates compose file with services configured for MQTT Message Bus 
                 The MQTT Broker service is also included. 
    zmq-bus:     Generates compose file with services configured for ZMQ Message Bus     
    ui:          Generates compose file with UI sevice included             
```
#### Clean

```
clean
Runs 'down' and removes all stopped containers, all volumes and all networks used by the EdgeX stack. Use this command when needing to do a fresh restart.
```

#### Get-token

```
get-token [options] 
Generates a Kong access token as specified by:
Options:
    arm64:  Generates a Kong access token using ARM64 image
    dev:    Generates a Kong access token using local dev built docker image
            'make docker', which creates docker images tagged with '0.0.0-dev'    
```
#### Upload-tls-cert

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

#### Get-consul-acl-token

```
get-consul-acl-token [options]
Retrieve the Consul ACL token as specified by:
Options:
    arm64:  Retrieves the Consul ACL token using ARM64 image
    dev:    Retrieves the Consul ACL token using local dev built docker image
            'make docker', which creates docker images tagged with '0.0.0-dev'
```

#### Compose

```
compose [options] 
Generates the EdgeX compose file as specified by options and stores them in the configured release folder. Compose files are named appropriatly for release and options used to generate them.

Options:
    no-secty:   Generates non-secure compose file, otherwise generates secure compose file
    arm64:      Generates compose file using ARM64 images
    dev:        Generates compose file using local dev built images from edgex-go repo's 
                'make docker' which creates docker images tagged with '0.0.0-dev'    
    app-dev:    Generates compose file using local dev built images from app-service-configurable repo's
                'make docker' which creates docker images tagged with '0.0.0-dev'
    ds-bacnet:  Generates compose file with device-bacnet included
    ds-camera:  Generates compose file with device-camera included
    ds-grove:   Generates compose file with device-grove included (valid only with arm64 option)
    ds-modbus:   Generates compose file with device-modbus included
    ds-mqtt:     Generates compose file with device-mqtt included
    ds-rest:     Generates compose file with device-rest included
    ds-snmp:     Generates compose file with device-snmp included
    ds-virtual:  Generates compose file with device-virtual included
    ds-coap:     Generates compose file with device-coap included
    ds-gpio:     Generates compose file with device-gpio included
    ds-llrp:     Generates compose file with device-rfid-llrp included
    modbus-sim:  Generates compose file with ModBus simulator included
    asc-http:    Generates compose file with App Service HTTP Export included
    asc-mqtt:    Generates compose file with App Service MQTT Export included
    asc-sample:  Generates compose file with App Service S included
    as-llrp:     Generates compose file with App RFID LLRP Inventory included
    mqtt-broker: Generates compose file with a MQTT Broker service included 
    mqtt-bus:    Generates compose file with services configure for MQTT Message Bus 
                 The MQTT Broker service is also included.
    zmq-bus:     Generates compose file with services configured for ZMQ Message Bus     
    ui:          Generates compose file with UI sevice included             
```

#### Taf-compose

```
taf-compose [options] 
Generates a TAF general testing compose file as specified by options and stores them in the configured TAF folder. Compose files are named appropriately for the options used to generate them.

Options:
    taf-secty:	  Generates general TAF testing compose file with security services
    taf-no-secty: Generates general TAF testing compose file without security services
    arm64:        Generates TAF compose file using ARM64 images
```

#### Taf-perf-compose

```
taf-perf-compose [options] 
Generates a TAF performance testing compose file as specified by options and stores them in the configured TAF folder. Compose files are named appropriately for the options used to generate them.

Options:
    taf-secty:	  Generates performance TAF testing compose file with security services
    taf-no-secty: Generates performance TAF testing compose file without security services
    arm64:        Generates TAF compose file using ARM64 images
```
