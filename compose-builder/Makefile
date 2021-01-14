# /*******************************************************************************
#  * Copyright 2020 Intel
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

.PHONY: help portainer portainer-down build build-ui run pull gen get-token upload-tls-cert ui-down down clean
.SILENT: help get-token del-token upload-tls-cert

include .env

COMPOSE_FILES:=-f docker-compose-base.yml
OPTIONS:=" arm64 no-secty mqtt dev ui ds-bacnet ds-camera ds-grove ds-modbus ds-mqtt ds-random ds-rest ds-snmp ds-virtual " # Must have spaces around words for `filter-out` function to work properly

ARGS:=$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

# Order of processing these arguments is important so the overrides in the 'add' compose files occur properly.
ifeq (dev, $(filter dev,$(ARGS)))
	CORE_EDGEX_REPOSITORY=edgexfoundry
	DEV:=-dev
	# matches the way that edgex-go to versioning the docker images for `make docker`
	CORE_EDGEX_VERSION:="0.0.0"
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
# Add/switch to use MQTT Message Bus
ifeq (mqtt, $(filter mqtt,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-messagebus.yml
	MQTT:=-mqtt
endif
# Add Security services and settings
ifeq (no-secty, $(filter no-secty,$(ARGS)))
	NO_SECURITY:=-no-secty
else
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-security.yml
endif
ifeq (ui, $(filter ui,$(ARGS)))
	COMPOSE_FILES:=-f docker-compose-ui.yml
	UI:=-ui
endif

SERVICES:=$(filter-out $(OPTIONS),$(ARGS))

ifeq (true, $(DS_GROVE))
 ifneq (-arm64, $(ARCH))
	 GROVE_CHECK:="ds-grove option only valid with arm64 option"
	 COMPOSE_FILES:=""
 endif
endif

COMPOSE_FOLDER:=../releases/nightly-build/compose-files
ifneq (nexus, $(RELEASE))
	COMPOSE_FOLDER:=../releases/$(RELEASE)/compose-files
endif

help:
	echo "See README.md in this folder"

portainer:
	make -C ../releases/nightly-build/compose-files portainer

portainer-down:
	make -C ../releases/nightly-build/compose-files portainer-down

build:
	make compose ds-rest ds-virtual
	make compose ds-rest ds-virtual arm64
	make compose ds-rest ds-virtual no-secty
	make compose ds-rest ds-virtual no-secty arm64
	make compose ui
	make compose ui arm64

compose: gen
	cat gen-header docker-compose.yml > $(COMPOSE_FOLDER)/docker-compose-$(RELEASE)$(UI)$(NO_SECURITY)$(MQTT)$(ARCH)$(DEV).yml

run: gen
	docker-compose -p edgex up -d $(SERVICES)

pull: gen
	docker-compose pull $(SERVICES)

gen:
	$(GROVE_CHECK) \
	DEV=$(DEV) \
	CORE_EDGEX_REPOSITORY=$(CORE_EDGEX_REPOSITORY) \
	CORE_EDGEX_VERSION=$(CORE_EDGEX_VERSION) \
	ARCH=$(ARCH) \
	KONG_UBUNTU=$(KONG_UBUNTU) \
	docker-compose -p edgex $(COMPOSE_FILES) config > docker-compose.yml

get-token:
	DEV=$(DEV) \
	ARCH=$(ARCH) \
	sh ./get-api-gateway-token.sh

upload-tls-cert:
	DEV=$(DEV) \
	ARCH=$(ARCH) \
	sh ./upload-api-gateway-cert.sh

ui-down:
	DEV= \
	CORE_EDGEX_REPOSITORY=$(CORE_EDGEX_REPOSITORY) \
	ARCH= \
	KONG_UBUNTU= \
	docker-compose -p edgex -f docker-compose-ui.yml down

down: ui-down
	DEV= \
	CORE_EDGEX_REPOSITORY=$(CORE_EDGEX_REPOSITORY) \
	ARCH= \
	KONG_UBUNTU= \
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
		-f add-mqtt-messagebus.yml \
		-f add-security.yml \
		down

clean: down
	-docker rm $$(docker ps --filter "network=edgex_edgex-network" --filter "network=edgex_default" -aq) 2> /dev/null
	docker volume prune -f && \
	docker network prune -f