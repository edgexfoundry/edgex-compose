## Edgex Docker Compose Builder

This folder contains the `Compose Builder` which is made up of **source** compose, **environment** files and a **makefile** for building the single file docker composes files. The `master` branch builds the `pre-release`  compose files which are placed in the top level of this repository. 

### **Note to Developers**: 
> *Once you have edited and tested your changes to these source files you **MUST** regenerate the standard `pre-release` compose files using the `make build` command.*
>
> Any options added or removed to/from the `make gen` and `make run` commands must to also be added/removed to/from the new` tui-generator.sh` script
>

### Compose CLI Command

The Makefile in this folder expects the `docker compose` CLI command to be on the path or it expects you to supply
a valid `docker compose` command by setting `DOCKER_COMPOSE`. The version of `docker compose` must be equal or greater 
than `Docker Compose version v2.24.4`. 

The old stand-alone `docker-compose` tool is no longer supported.
See https://docs.docker.com/compose/install/ for installation details for the latest `docker compose` CLI command.

### Generate next release compose files

Do the following to generate the compose files for next release such as `minnesota`

1. Create the new `release` branch from this branch, i.e create the `minnesota` branch (**Now done by DevOps release processes**)
2. Checkout a new working branch from the new `release` branch
3. Update the `REPOSITORY`, `CORE_EDGEX_REPOSITORY` and `APP_SVC_REPOSITORY` (**Now done by DevOps release processes**)
4. Update `versions` contained in the `.env` file appropriately for the new release
5. Run `make build` 
6. Update the two READMEs to be specific to the new `release`
7. Commit changes, open PR and merge PR
8. TAG the new release branch (**Now done by DevOps release processes**)
9. Update EdgeX documentation to refer to the new release branch. (**Now done by DevOps release processes**)

### Generate dot release compose files

1. Checkout a new working branch from the target `release` branch for the dot release, i.e the `jakarta` branch
2. Update the and `versions` contained in the `.env` file appropriately for the dot release
3. Run `make build` 
4. Commit changes, open PR and merge PR
5. TAG the release branch for the dot release (**Now done by DevOps release processes**)

### Multiple Compose files approach

The approach used with these source compose files is the `Extending using multiple Compose files` described here: https://docs.docker.com/compose/extends/#multiple-compose-files

The `Extending using multiple Compose files` approach along with environment files removes the all of the duplication found in earlier EdgeX compose files. This approach makes running the solution more complicated due to having to list the multiple compose files required to run a particular configuration. To alleviate this complexity we provide generated single file compose files one level up. A `Makefile` has been provided here with commands that make it easy to run one of the multiple possible configurations while testing your changes. See the Makefile section below for details on these commands.

> *Note: The `make run`, `make pull` and `make gen` commands all generate a single `docker-compose.yml` file containing the content from the multiple compose files, environment files with all variables resolved for the specified options used. See below for list of options.*

### Compose Files

This folder contains the following compose files:

- **docker-compose-base.yml**<br/>
  Base non-secure mode compose file. Contains all the services that run in the non-secure configuration, including the UI.  
- **add-security.yml**<br/>
    Security **extending** compose file. Adds the additional security services and configuration of services so that all the services are running in the secure configuration.
- **add-secure-redis-messagebus.yml**<br/>
    Secure Redis MessageBus **extending** compose file. Adds the additional security configuration for when Redis is used as MessageBus in secure mode so Kuiper can connect to the secure MessageBus.
- **add-delayed-start-services.yml**<br/>
    Secure delayed start services **extending** compose file. Adds additional delayed start services based on spire/spiffe implementation to provide the secret store token on the runtime secure configuration.
- **add-device-bacnet-ip.yml**<br/>
    Device Service **extending** compose file, which adds the **Device Bacnet(IP)**  service.
- **add-device-bacnet-mstp.yml**<br/>
  Device Service **extending** compose file, which adds the **Device Bacnet(MSTP)**  service.
- **add-device-onvif-camera.yml**<br/>
    Device Service **extending** compose file, which adds the **Device ONVIF Camera**  service.
- **add-device-usb-camera.yml**<br/>
    Device Service **extending** compose file, which adds the **Device USB Camera**  service.
- **add-device-modbus.yml**<br/>
    Device Service **extending** compose file, which adds the **Device Modbus**  service.
- **add-device-mqtt.yml**<br/>
    Device Service **extending** compose file, which adds the **Device MQTT**  service.
- **add-secure-device-mqtt.yml**<br/>
    Device Service **extending** compose file, which adds the **Secure Device MQTT**  service.
- **add-device-rest.yml**<br/>
    Device Service **extending** compose file, which adds the **Device REST** service.
- **add-device-snmp.yml**<br/>
    Device Service **extending** compose file, which adds the **Device SNMP**  service.
- **add-device-virtual.yml**<br/>
    Device Service **extending** compose file, which adds the **Device Virtual**  service.
- **add-device-virtual.yml**<br/>
    Device Service **extending** compose file, which adds the **Device Virtual**  service.
- **add-device-coap.yml**<br/>
    Device Service **extending** compose file, which adds the **Device COAP** service.
- **add-device-gpio.yml**<br/>
    Device Service **extending** compose file, which adds the **Device GPIO**  service.
- **add-device-uart.yml**<br/>
    Device Service **extending** compose file, which adds the **Device UART**  service.
- **add-device-rfid-llrp.yml**<br/>
    Device Service **extending** compose file, which adds the **Device RFID LLRP**  service.
- **add-device-s7.yml**<br/>
    Device Service **extending** compose file, which adds the **Device S7**  service.
- **add-asc-http-export.yml**<br/>
    Application Service Configurable **extending** compose file, which adds the **App Service Http Export**  service. Additional configuration required. See [http-export profile](https://docs.edgexfoundry.org/2.2/microservices/application/AppServiceConfigurable/#http-export) for details
- **add-asc-mqtt-export.yml**<br/>
    Application Service Configurable **extending** compose file, which adds the **App Service MQTT Export**  service. Additional configuration required. See [mqtt-export profile](https://docs.edgexfoundry.org/2.2/microservices/application/AppServiceConfigurable/#mqtt-export) for details
- **add-asc-metrics-influxdb.yml**<br/>
    Application Service Configurable **extending** compose file, which adds the **App Service Metrics Infludb**  service.  Additional configuration required. See [metrics-influxdb profile](https://docs.edgexfoundry.org/2.2/microservices/application/AppServiceConfigurable/#metrics-influxdb) for details
- **add-asc-sample.yml**<br/>
    Application Service Configurable **extending** compose file, which adds the **App Service Sample**  service.
- **add-asc-external-mqtt-trigger.yml**<br/>
    Application Service Configurable **extending** compose file, which adds the **App Service External MQTT Trigger**  service.
- **add-app-rfid-llrp-inventory.yml**<br/>
    Application Service **extending** compose file, which adds the **RFID LLRP Inventory**  app service.
- **add-app-record-replay.yml**<br/>
    Application Service **extending** compose file, which adds the **Record & Replay** app service.
- **add-service-secure-template.yml**<br/>
    A template for a single service **extending** compose file from its base service for security mode,
    and the service is enabled with secret store by default.
- **add-modbus-simulator.yml**<br/>
    ModBus Simulator **extending** compose file. Adds the MQTT ModBus Simulator service. Must be used in conjunction with  **add-device-modbus.yml**
- **add-mqtt-broker-mosquitto.yml**<br/>
    MQTT Broker **extending** compose file. Adds the Eclipse Mosquitto MQTT Broker.
- **add-mqtt-broker-nanomq.yml**<br/>
    MQTT Broker **extending** compose file. Adds the NanoMQ MQTT Broker. **## Experimental ##**
- **add-secure-mqtt-broker.yml**<br/>
    MQTT Broker **extending** compose file. Adds the Secure Eclipse Mosquitto MQTT Broker. 
- **add-mqtt-messagebus.yml**<br/>
    MQTT MesssageBus **extending** compose file. Adds additional configuration of services so that the `MQTT` implementation of the Edgex Message Bus is used. **Must be used in conjunction with add-mqtt-broker.yml**
- **add-secure-mqtt-messagebus.yml**<br/>
    MQTT MesssageBus **extending** compose file. Adds additional configuration of services so that the Secure `MQTT` implementation of the Edgex Message Bus is used. **Must be used in conjunction with add-secure-mqtt-broker.yml**
- **add-nats-messagebus.yml**<br/>
    NATS MesssageBus **extending** compose file. Adds NATS Server and additional configuration of services so that the `NATS` implementation of the Edgex Message Bus is used. 
- **add-taf-app-services.yml**<br/>
    TAF App Services **extending** compose file. Adds additional App Service for the TAF testing compose files.
- **add-taf-app-services-secure.yml**<br/>
    TAF App Services **extending** `add-taf-app-services` compose file, and services are enabled with secret store by default.
- **add-taf-device-services-mods.yml**<br/>
    TAF Device Services **extending** compose file. Modifies setting of Device Virtual and Device Modbus for the TAF testing compose files. **Must be used in conjunction with add-device-modbus.yml and add-device-virtual.yml**
- **add-keeper.yml**<br/>
    Registry Service **extending** compose file. Adds the **Core Keeper** service.
- **add-consul.yml**<br/>
    Registry Service **extending** compose file. Adds the **Consul** service.

### Environment Files

This folder contains the following environment files:

- **.env**
    This file contains the `version`, `repositories` and image `version` variables referenced in compose files. Docker compose implicitly uses the `.env` file, if it exists, so you will not see it referenced in the compose files. It is referenced in the Makefile so that it can also use these settings.

- **common-non-security.env**
    This file contains the common non-security related environment overrides used by all Edgex services.

- **common-security.env**
    This file contains the common security related environment overrides used by many Edgex services.

- **common-sec-stage-gate.env**
    This file contains the common security-bootstrapper stage gate related environment overrides used by many Edgex services.

### TUI (terminal UI)

Compose builder now has the TUI Generator tool that provides menus to select the options described in the [Makefile](#makefile) section below for generation and running of custom compose files. To use this tool simply run `./tui-generator.sh` in a Linux terminal from the `compose-builder` folder.

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
   full secure with app-sample (docker-compose-with-app-sample.yml)
   full secure with app-sample for arm64 (docker-compose-with-app-sample-arm64.yml)
   non-secure (docker-compose-no-secty.yml)
   non-secure for arm64 (docker-compose-no-secty-arm64.yml)
   non-secure with app-sample (docker-compose-no-secty-with-app-sample.yml)
   non-secure with app-sample for arm64 (docker-compose-no-secty-with-app-sample-arm64.yml)

 TAF compose variations are:
   full secure general testing (docker-compose-taf.yml)
   full secure general testing for arm64 (docker-compose-taf-arm64.yml)
   non-secure general testing (docker-compose-taf-no-secty.yml)
   non-secure general testing for arm64 (docker-compose-taf-no-secty-arm64.yml)
   full secure perf testing (docker-compose-taf-perf.yml)
   full secure perf testing for arm64 (docker-compose-taf-perf-arm64.yml)
   non-secure perf testing (docker-compose-taf-perf-no-secty.yml)
   non-secure perf testing for arm64 (docker-compose-taf-perf-no-secty-arm64.yml)
   full secure general testing with mqtt-bus (docker-compose-taf-mqtt-bus.yml)
   full secure general testing with mqtt-bus for arm64 (docker-compose-taf-mqtt-bus-arm64.yml)
   non-secure general testing with mqtt-bus (docker-compose-taf-no-secty-mqtt-bus.yml)
   non-secure general testing with mqtt-bus for arm64 (docker-compose-taf-no-secty-mqtt-bus-arm64.yml)
   full secure general testing with core-keeper (docker-compose-taf-keeper.yml)
   full secure general testing with core-keeper for arm64 (docker-compose-taf-keeper-arm64.yml)
   non-secure general testing with core-keeper (docker-compose-taf-no-secty-keeper.yml)
   non-secure general testing with core-keeper for arm64 (docker-compose-taf-no-secty-keeper-arm64.yml)
   full secure general testing with mqtt-bus with core-keeper (docker-compose-taf-mqtt-bus-keeper.yml)
   full secure general testing with mqtt-bus with core-keeper for arm64 (docker-compose-taf-mqtt-bus-keeper-arm64.yml)
   non-secure general testing with mqtt-bus with core-keeper (docker-compose-taf-no-secty-mqtt-bus-keeper.yml)
   non-secure general testing with mqtt-bus with core-keeper for arm64 (docker-compose-taf-no-secty-mqtt-bus-keeper-arm64.yml)
```
#### Run

```
run [options] [services]
Runs the EdgeX services as specified by:
Options:
    zero-trust:       Runs with OpenZiti support for zero-trust networking
    no-secty:         Runs in Non-Secure Mode, otherwise runs in Secure Mode
    arm64:            Runs using ARM64 images
    dev:              Runs using local built images from edgex-go repo
                      'make docker' creates local docker images tagged with '0.0.0-dev'
    app-dev:          Runs using local built images from application service repos
                      'make docker' creates local docker images tagged with '0.0.0-dev`
    device-dev:       Runs using local built images from device service repos
                      'make docker' creates local docker images tagged with '0.0.0-dev'
    ui-dev:           Runs using local built images from edgex-ui-go repo
                      'make docker' creates local docker image tagged with '0.0.0-dev'
    delayed-start:    Runs with delayed start services- 
                      spire related services and spiffe-token-provider service included
    ds-modbus:        Runs with device-modbus included
    ds-bacnet-ip:     Runs with device-bacnet-ip included
    ds-bacnet-mstp:   Runs with device-bacnet-mstp included
    ds-onvif-camera:  Runs with device-onvif-camera included
    ds-usb-camera:    Runs with device-usb-camera included
    ds-mqtt:          Runs with device-mqtt included
    ds-rest:          Runs with device-rest included
    ds-snmp:          Runs with device-snmp included
    ds-virtual:       Runs with device-virtual included
    ds-coap:          Runs with device-coap included
    ds-gpio:          Runs with device-gpio included
    ds-uart:          Runs with device-uart included
    ds-llrp:          Runs with device-rfid-llrp included
    ds-s7:            Runs with device-s7 included
    modbus-sim:       Runs with ModBus simulator included
    asc-http:         Runs with App Service HTTP Export included
    asc-mqtt:         Runs with App Service MQTT Export included
    asc-metrics:      Runs with App Service Metrics InfluxDb included
    asc-sample:       Runs with App Service Sample included
    as-llrp:          Runs with App RFID LLRP Inventory included
    as-record-replay: Runs with App Record & Replay included
    asc-ex-mqtt:      Runs with App Service External MQTT Trigger included
    mqtt-broker:      Runs with a MQTT Broker service included
    mqtt-bus:         Runs with services configure for MQTT Message Bus
                      The MQTT Broker service is also included.
    mqtt-verbose:     Enables MQTT Broker verbose logging.
    nanomq:           ** Experimental ** 
                      Uses NonoMQ MQTT broker when mqtt-broker or mqtt-bus are specified
                      Not valid in secure mode when uses with mqtt-bus
    nats-bus:         Runs with services configure for NATS Message Bus
                      The NATS Server service is also included.
    no-cleanup:       Leaves generated files behind for debugging purposes.
    keeper:           Runs to registry service to core-keeper
Services:
    <names...>: Runs only services listed (and their dependent services) where 'name' matches a service name in one of the compose files used
```
#### Up

```
up
Start all Edgex services using the docker-compose.yml file resulting from last time "make gen" was run. Use this command when the docker-compose.yml file has been modified after generating it. This command Will result in error if the docker-compose.yml file doesn't exist.
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
    zero-trust:       Pulls images for OpenZiti, supporting zero-trust networking
    no-secty:         Pulls images for Non-Secure Mode, otherwise pull images 
                      for Secure Mode
    arm64:            Pulls ARM64 version of images
    delayed-start:    Pull includes delayed start services- spire related services 
                      and spiffe-token-provider service
    ds-bacnet-ip:     Pull includes device-bacnet-ip
    ds-bacnet-mstp:   Pull includes device-bacnet-mstp
    ds-onvif-camera:  Pull includes device-onvif-camera included
    ds-usb-camera:    Pull includes device-usb-camera included
    ds-modbus:        Pull includes device-modbus
    ds-mqtt:          Pull includes device-mqtt
    ds-rest:          Pull includes device-rest
    ds-snmp:          Pull includes device-snmp
    ds-virtual:       Pull includes device-virtual
    ds-coap:          Pull includes device-coap
    ds-gpio:          Pull includes device-gpio
    ds-uart:          Pull includes device-uart
    ds-llrp:          Pull includes device-rfid-llrp
    ds-s7:            Pull includes device-s7
    modbus-sim:       Pull includes ModBus simulator
    asc-http:         Pull includes App Service HTTP Export
    asc-mqtt:         Pull includes App Service MQTT Export
    asc-metrics:      Pull includes App Service Metrics InfluxDb included
    asc-sample:       Pull includes App Service Sample
    as-llrp:          Pull includes App RFID LLRP Inventory
    as-record-replay: Pull includes App Record & Replay
    asc-ex-mqtt:      Pull includes App Service External MQTT Trigger
    mqtt-broker:      Pull includes MQTT Broker service
    mqtt-bus:         Pull includes additional services for MQTT Message Bus
    nanomq:           ** Experimental ** 
                      Pull includes NonoMQ MQTT broker when mqtt-broker or mqtt-bus are specified
                      Not valid in secure mode when uses with mqtt-bus                    
    nats-bus:         Pull includes additional services for NATS Message Bus
    no-cleanup:       Leaves generated files behind for debugging purposes
    keeper:           Pull includes core-keeper

Services:
    <names...>: Pulls only images for the service(s) listed
```
#### Gen

```	
gen [options]
Generates temporary single file compose file (`docker-compose.yml`) as specified by:
Options:
    zero-trust:       Generates with OpenZiti support for zero-trust networking included
    no-secty:         Generates non-secure compose,
                      otherwise generates secure compose file
    arm64:            Generates compose file using ARM64 images
    dev:              Generates using local built images from edgex-go repo
                      'make docker' creates local docker images tagged with '0.0.0-dev'
    app-dev:          Generates using local built images from application service repos
                      'make docker' creates local docker images tagged with '0.0.0-dev`
    device-dev:       Generates using local built images from device service repos
                      'make docker' creates local docker images tagged with '0.0.0-dev'
    ui-dev:           Generates using local built images from edgex-ui-go repo
                      'make docker' creates local docker image tagged with '0.0.0-dev'
    delayed-start:    Generates compose file with delayed start services- spire 
                      related services and spiffe-token-provider service included
    ds-modbus:        Generates compose file with device-modbus included
    ds-bacnet-ip:     Generates compose file with device-bacnet-ip included
    ds-bacnet-mstp:   Generates compose file with device-bacnet-mstp included
    ds-onvif-camera:  Generates compose file with device-onvif-camera included
    ds-usb-camera:    Generates compose file with device-usb-camera included
    ds-mqtt:          Generates compose file with device-mqtt included
    ds-rest:          Generates compose file with device-rest included
    ds-snmp:          Generates compose file with device-snmp included
    ds-virtual:       Generates compose file with device-virtual included
    ds-coap:          Generates compose file with device-coap included
    ds-gpio:          Generates compose file with device-gpio included
    ds-uart:          Generates compose file with device-uart included
    ds-llrp:          Generates compose file with device-rfid-llrp included
    ds-s7:            Generates compose file with device-s7 included
    modbus-sim:       Generates compose file with ModBus simulator included
    asc-http:         Generates compose file with App Service HTTP Export included
    asc-mqtt:         Generates compose file with App Service MQTT Export included
    asc-metrics:      Generates compose file with App Service Metrics InfluxDb included
    asc-sample:       Generates compose file with App Service Sample included
    as-llrp:          Generates compose file with App RFID LLRP Inventory included
    as-record-replay: Generates compose file with App Record & Replay included
    asc-ex-mqtt:      Generates compose file with App Service External MQTT Trigger included
    mqtt-broker:      Generates compose file with a MQTT Broker service included
    mqtt-bus:         Generates compose file with services configured for MQTT Message Bus
                      The MQTT Broker service is also included.
    mqtt-verbose      Enables MQTT Broker verbose logging.
    nanomq:           ** Experimental ** 
                      Generates compose file with NonoMQ MQTT broker when mqtt-broker or mqtt-bus are specified
                      Not valid in secure mode when uses with mqtt-bus
    nats-bus:         Generates compose file with services configured for NAT Message Bus
                      The NATS Server service is also included.
    no-cleanup:       Leaves generated files behind for debugging purposes.
    keeper:           Generates compose file with services registry to core-keeper
                      The core-keeper service is also included
```
#### Clean

```
clean
Runs 'down' and removes all stopped containers, all volumes and all networks used by the EdgeX stack. Use this command when needing to do a fresh restart.
```

#### Get-token

```
get-token [options] 
Generates a API gateway access token as specified by:
Options:
    arm64:  Generates a API gateway access token using ARM64 image
    dev:    Generates a API gateway access token using local dev built docker image
            'make docker' creates local docker images tagged with '0.0.0-dev'    
```
#### Upload-tls-cert

```
upload-tls-cert [options] <environment_variables>
Upload a bring-your-own (BYO) TLS certificate to the API gateway as specified by:
Options:
    arm64:  Upload TLS certificate to the API gateway server using ARM64 image
    dev:    Upload TLS certificate to the API gateway server using local dev built docker image
            'make docker' creates local docker images tagged with '0.0.0-dev'    
    Environment Variables: 
    CERT_INPUT_FILE=<full_path_to_cert_file>: the full file name path to your own certificate file, this is required
    KEY_INPUT_FILE=<full_path_to_key_file>: the full file name path to your own key file, this is required
```

#### Get-consul-acl-token

```
get-consul-acl-token 
Retrieves the Consul ACL token
```

#### Build Canned
```
build-canned

Generates all the canned standard EdgeX compose files in the top level folder
```

#### Build Taf
```
build-taf

Generates all the EdgeX TAF test compose files in the /taf folder
```

#### Build Taf NanoMq
```
build-taf-nanomq

Generates the non-secure MQTT MessageBus EdgeX TAF testing compose files with NanoMQ for the MQTT Broker in the /taf folder
```

#### Compose

```
compose [options] 
Generates the EdgeX compose file as specified by options and stores them in the configured release folder. Compose files are named appropriately for release and options used to generate them.

Options:
    zero-trust:       Generates compose file with OpenZiti support for zero-trust networking included
    no-secty:         Generates non-secure compose file, otherwise generates secure compose file
    arm64:            Generates compose file using ARM64 images
    dev:              Generates using local built images from edgex-go repo
                      'make docker' creates local docker images tagged with '0.0.0-dev'
    app-dev:          Generates using local built images from application service repos
                      'make docker' creates local docker images tagged with '0.0.0-dev`
    device-dev:       Generates using local built images from device service repos
                      'make docker' creates local docker images tagged with '0.0.0-dev'
    ui-dev:           Generates using local built images from edgex-ui-go repo
                      'make docker' creates local docker image tagged with '0.0.0-dev'
    delayed-start:    Generates compose file with delayed start services- spire related services and
                      spiffe-token-provider service included
    ds-bacnet-ip:     Generates compose file with device-bacnet-ip included
    ds-bacnet-mstp:   Generates compose file with device-bacnet-mstp included
    ds-onvif-camera:  Generates compose file with device-onvif-camera included
    ds-usb-camera:    Generates compose file with device-usb-camera included
    ds-modbus:        Generates compose file with device-modbus included
    ds-mqtt:          Generates compose file with device-mqtt included
    ds-rest:          Generates compose file with device-rest included
    ds-snmp:          Generates compose file with device-snmp included
    ds-virtual:       Generates compose file with device-virtual included
    ds-coap:          Generates compose file with device-coap included
    ds-gpio:          Generates compose file with device-gpio included
    ds-uart:          Generates compose file with device-uart included
    ds-llrp:          Generates compose file with device-rfid-llrp included
    ds-s7:            Generates compose file with device-s7 included
    modbus-sim:       Generates compose file with ModBus simulator included
    asc-http:         Generates compose file with App Service HTTP Export included
    asc-mqtt:         Generates compose file with App Service MQTT Export included
    asc-metrics:      Generates compose file with App Service Metrics InfluxDb included
    asc-sample:       Generates compose file with App Service Sample included
    as-llrp:          Generates compose file with App RFID LLRP Inventory included
    as-record-replay: Generates compose file with App Record & Replay included
    asc-ex-mqtt:      Generates compose file with App Service External MQTT Trigger included
    mqtt-broker:      Generates compose file with a MQTT Broker service included
    mqtt-bus:         Generates compose file with services configure for MQTT Message Bus
                      The MQTT Broker service is also included.
    nanomq:           ** Experimental ** 
                      Generates compose file with NonoMQ MQTT broker when mqtt-broker or mqtt-bus are specified
                      Not valid in secure mode when uses with mqtt-bus
    mqtt-verbose      Enables MQTT Broker verbose logging.
    nats-bus:         Generates compose file with services configure for NATS Message Bus
                      The NATS Server service is also included.
    no-cleanup:       Leaves generated files behind for debugging purposes.
    keeper:           Generates compose file to registry service to core-keeper
```

#### TAF Compose

```
taf-compose [options] 
Generates a TAF general testing compose file as specified by options and stores them in the configured TAF folder. Compose files are named appropriately for the options used to generate them.

Options:
    taf-secty:	  Generates general TAF testing compose file with security services
    taf-no-secty: Generates general TAF testing compose file without security services
    arm64:        Generates TAF compose file using ARM64 images
    keeper:       Generates compose file to registry service to core-keeper
```

#### Taf Perf Compose

```
taf-perf-compose [options] 
Generates a TAF performance testing compose file as specified by options and stores them in the configured TAF folder. Compose files are named appropriately for the options used to generate them.

Options:
    taf-secty:	  Generates performance TAF testing compose file with security services
    taf-no-secty: Generates performance TAF testing compose file without security services
    arm64:        Generates TAF compose file using ARM64 images
```
