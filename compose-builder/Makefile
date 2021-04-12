# /*******************************************************************************
#  * Copyright 2021 Intel
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
#  * in compliance with the License. You may obtain a copy of the License at
#  *
#  * http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software distributed under the License
#  * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#  * or implied. See the License for the specific language governing permissions and limitations under
#  * the License.
#  *
#  *******************************************************************************/

.PHONY: help portainer portainer-down \
	build compose run pull gen \
	build-taf taf-compose taf-compose-perf \
	get-token upload-tls-cert get-consul-acl-token \
	ui-down down clean
.SILENT: help get-token del-token upload-tls-cert get-consul-acl-token

include .env

COMPOSE_FILES:=-f docker-compose-base.yml
TOKEN_LIST:=""

# Must have spaces around words for `filter-out` function to work properly.
# Dashes at beginning & end of line ensure space before/after the first/last option on that line
# and don't impact the option list
define OPTIONS
 - arm64 no-secty dev app-dev -
 - mqtt-bus mqtt-broker -
 - taf-secty taf-no-secty taf-perf taf-perf-no-secty -
 - ds-bacnet ds-camera ds-grove ds-modbus ds-mqtt ds-random ds-rest ds-snmp ds-virtual -
 - asc-http asc-mqtt -
 - modbus-sim ui ui-only -
endef
export OPTIONS



ARGS:=$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

# Order of processing these arguments is important so the overrides in the 'add' compose files occur properly.
ifeq (dev, $(filter dev,$(ARGS)))
	CORE_EDGEX_REPOSITORY=edgexfoundry
	DEV:=-dev
	# matches the way that edgex-go to versioning the docker images for `make docker`
	CORE_EDGEX_VERSION:="0.0.0"
endif
ifeq (app-dev, $(filter app-dev,$(ARGS)))
	APP_SVC_REPOSITORY=edgexfoundry
	APP_SVC_DEV:=-dev
endif
ifeq (arm64, $(filter arm64,$(ARGS)))
	ARCH:=-arm64
	KONG_UBUNTU:=-ubuntu
endif

# Add Device Services
ifeq (ds-bacnet, $(filter ds-bacnet,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-bacnet.yml
endif
ifeq (ds-camera, $(filter ds-camera,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-camera.yml
endif
ifeq (ds-grove, $(filter ds-grove,$(ARGS)))
    DS_GROVE:=true
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-grove.yml
endif
ifeq (ds-modbus, $(filter ds-modbus,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-modbus.yml
endif
ifeq (ds-mqtt, $(filter ds-mqtt,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-mqtt.yml
endif
ifeq (ds-random, $(filter ds-random,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-random.yml
endif
ifeq (ds-rest, $(filter ds-rest,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-rest.yml
endif
ifeq (ds-snmp, $(filter ds-snmp,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-snmp.yml
endif
ifeq (ds-virtual, $(filter ds-virtual,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-virtual.yml
endif

# Add ModBus Simulator
ifeq (modbus-sim, $(filter modbus-sim,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-modbus-simulator.yml
endif

# Add Application Services
ifeq (asc-http, $(filter asc-http,$(ARGS)))
	# always add the base
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-http-export.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=app-http-export
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-http-export
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-http-export-secure.yml
	endif
endif
ifeq (asc-mqtt, $(filter asc-mqtt,$(ARGS)))
	# always add the base
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-mqtt-export.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=app-mqtt-export
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-mqtt-export
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-mqtt-export-secure.yml
	endif
endif

# Add a MQTT Broker
ifeq (mqtt-broker, $(filter mqtt-broker,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-broker.yml
	MQTT:=-mqtt
endif

# Add switch to use MQTT Message Bus
ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-messagebus.yml -f add-mqtt-broker.yml
	MQTT:=-mqtt
endif

# Add Security services and settings
ifeq (no-secty, $(filter no-secty,$(ARGS)))
	NO_SECURITY:=-no-secty
else
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-security.yml
endif

ifeq (ui, $(filter ui,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-ui.yml
endif

ifeq (ui-only, $(filter ui-only,$(ARGS)))
	COMPOSE_FILES:=-f stand-alone-ui.yml -f add-ui.yml
	UI:=-ui
endif

# Build compose for TAF secure testing (ignore all other compose file options)
ifeq (taf-secty, $(filter taf-secty,$(ARGS)))
	TOKEN_LIST:=app-http-export,app-mqtt-export,app-functional-tests
	COMPOSE_FILES:= \
		-f docker-compose-base.yml \
		-f add-security.yml \
		-f add-taf-app-services.yml \
		-f add-taf-app-services-secure.yml \
		-f add-asc-http-export.yml \
		-f add-asc-http-export-secure.yml \
		-f add-asc-mqtt-export.yml \
		-f add-asc-mqtt-export-secure.yml \
		-f add-device-virtual.yml \
		-f add-device-rest.yml \
		-f add-device-modbus.yml \
		-f add-taf-device-services-mods.yml \
		-f add-mqtt-broker.yml \
		-f add-modbus-simulator.yml
else
	# Build compose for TAF non-secure testing (ignore all other compose file options)
    ifeq (taf-no-secty, $(filter taf-no-secty,$(ARGS)))
		COMPOSE_FILES:= \
			-f docker-compose-base.yml \
			-f add-taf-app-services.yml \
			-f add-asc-http-export.yml \
			-f add-asc-mqtt-export.yml \
			-f add-device-virtual.yml \
			-f add-device-rest.yml \
			-f add-device-modbus.yml \
			-f add-taf-device-services-mods.yml \
			-f add-mqtt-broker.yml \
			-f add-modbus-simulator.yml
        NO_SECURITY:=-no-secty
    else
    	# Build compose for TAF secure performance testing (ignore all other compose file options)
    	ifeq (taf-perf, $(filter taf-perf,$(ARGS)))
			TOKEN_LIST:=app-http-export,app-mqtt-export,app-functional-tests
    		COMPOSE_FILES:= \
    			-f docker-compose-base.yml \
    			-f add-security.yml \
    			-f add-asc-mqtt-export.yml \
    			-f add-asc-mqtt-export-secure.yml \
    			-f add-device-virtual.yml \
    			-f add-device-rest.yml \
    			-f add-mqtt-broker.yml
    	else
			# Build compose for TAF non-secure performance testing (ignore all other compose file options)
			ifeq (taf-perf-no-secty, $(filter taf-perf-no-secty,$(ARGS)))
				COMPOSE_FILES:= \
					-f docker-compose-base.yml \
					-f add-asc-mqtt-export.yml \
					-f add-device-virtual.yml \
					-f add-device-rest.yml \
					-f add-mqtt-broker.yml
				NO_SECURITY:=-no-secty
			endif
		endif
	endif
endif

SERVICES:=$(filter-out ${OPTIONS},$(ARGS))

ifeq (true, $(DS_GROVE))
 ifneq (-arm64, $(ARCH))
	 GROVE_CHECK:="ds-grove option only valid with arm64 option"
	 COMPOSE_FILES:=""
 endif
endif

help:
	echo "See README.md in this folder"

portainer:
	make -C ${RELEASE_FOLDER} portainer

portainer-down:
	make -C ${RELEASE_FOLDER} portainer-down

build:
	make compose ds-rest ds-virtual
	make compose ds-rest ds-virtual arm64
	make compose ds-rest ds-virtual no-secty
	make compose ds-rest ds-virtual no-secty arm64
	make compose ui-only
	make compose ui-only arm64
	make taf-compose taf-secty
	make taf-compose taf-no-secty
	make taf-compose taf-secty arm64
	make taf-compose taf-no-secty arm64
	make taf-compose-perf taf-perf
	make taf-compose-perf taf-perf-no-secty
	make taf-compose-perf taf-perf arm64
	make taf-compose-perf taf-perf-no-secty arm64

compose: gen
	cat gen-header docker-compose.yml > $(RELEASE_FOLDER)/docker-compose-$(RELEASE)$(UI)$(NO_SECURITY)$(MQTT)$(ARCH).yml

taf-compose: gen
	cat gen-header docker-compose.yml > $(RELEASE_FOLDER)/taf/docker-compose-taf$(NO_SECURITY)$(MQTT)$(ARCH).yml

taf-compose-perf: gen
	cat gen-header docker-compose.yml > $(RELEASE_FOLDER)/taf/docker-compose-taf-perf$(NO_SECURITY)$(MQTT)$(ARCH).yml

run: gen
	docker-compose -p edgex up -d $(SERVICES)

pull: gen
	docker-compose pull $(SERVICES)

gen:
	$(GROVE_CHECK) \
	DEV=$(DEV) \
	APP_SVC_DEV=$(APP_SVC_DEV) \
	CORE_EDGEX_REPOSITORY=$(CORE_EDGEX_REPOSITORY) \
	CORE_EDGEX_VERSION=$(CORE_EDGEX_VERSION) \
	APP_SVC_REPOSITORY=$(APP_SVC_REPOSITORY) \
	ARCH=$(ARCH) \
	TOKEN_LIST=$(TOKEN_LIST) \
	docker-compose -p edgex $(COMPOSE_FILES) config > docker-compose.yml

get-token:
	DEV=$(DEV) \
	ARCH=$(ARCH) \
	sh ./get-api-gateway-token.sh

upload-tls-cert:
	DEV=$(DEV) \
	ARCH=$(ARCH) \
	sh ./upload-api-gateway-cert.sh

get-consul-acl-token:
	DEV=$(DEV) \
	ARCH=$(ARCH) \
	sh ./get-consul-acl-token.sh

ui-down:
	ARCH= \
	docker-compose -p edgex -f stand-alone-ui.yml -f add-ui.yml down

down: ui-down
	DEV= \
	APP_SVC_DEV= \
	ARCH= \
	TOKEN_LIST= \
	docker-compose -p edgex \
		-f docker-compose-base.yml \
		-f add-device-bacnet.yml \
		-f add-device-camera.yml \
		-f add-device-grove.yml \
		-f add-device-modbus.yml \
		-f add-device-mqtt.yml \
		-f add-device-random.yml \
		-f add-device-rest.yml \
		-f add-device-snmp.yml \
		-f add-device-virtual.yml \
		-f add-asc-http-export.yml \
		-f add-asc-http-export-secure.yml \
		-f add-asc-mqtt-export.yml \
		-f add-asc-mqtt-export-secure.yml \
		-f add-modbus-simulator.yml \
		-f add-mqtt-broker.yml \
		-f add-mqtt-messagebus.yml \
		-f add-security.yml \
		down

clean: down
	-docker rm $$(docker ps --filter "network=edgex_edgex-network" --filter "network=edgex_default" -aq) 2> /dev/null
	docker volume prune -f && \
	docker network prune -f