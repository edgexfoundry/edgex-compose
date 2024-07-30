# /*******************************************************************************
#  * Copyright 2023 Intel
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
	build build-canned compose run pull gen \
	build-taf taf-compose taf-compose-perf \
	get-token upload-tls-cert get-consul-acl-token \
    down clean err
.SILENT: help get-token del-token upload-tls-cert get-consul-acl-token

include .env
include common-security.env

# This tool now only supports compose V2, aka "docker compose" as it has replaced to old docker-compose tool.
DOCKER_COMPOSE?=docker compose
GEN_COMMAND=convert

COMPOSE_FILES:=-f docker-compose-base.yml
TOKEN_LIST=
KNOWN_SECRETS_LIST=redisdb[app-rules-engine]
EXTRA_PROXY_ROUTE_LIST=
GEN_EXT_DIR=gen_ext_compose
BUS=
NANOMQ=
REGISTRY=

BROKER_YAML=add-mqtt-broker-mosquitto.yml
TAF_BROKER_YAML=add-taf-mqtt-broker-mosquitto.yml

# Must have spaces around words for `filter-out` function to work properly.
# Dashes at beginning & end of line ensure space before/after the first/last option on that line
# and don't impact the option list
define OPTIONS
 - arm64 no-secty dev app-dev device-dev ui-dev delayed-start -
 - nats-bus mqtt-bus mqtt-broker mqtt-verbose nanomq -
 - taf-secty taf-no-secty taf-perf taf-perf-no-secty -
 - ds-onvif-camera ds-usb-camera ds-bacnet-ip ds-bacnet-mstp ds-modbus ds-mqtt ds-rest ds-snmp ds-virtual ds-llrp -
 - ds-coap ds-gpio ds-uart ds-s7 -
 - asc-http asc-mqtt asc-sample asc-metrics as-llrp as-record-replay asc-ex-mqtt -
 - modbus-sim zero-trust no-cleanup -
 - consul keeper -
endef
export OPTIONS

ARGS:=$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

# Order of processing these arguments is important so the overrides in the 'add' compose files occur properly.

# if using the NATS bus, must then also use dev, app-dev and device-dev since NATS is only available if
# built local dev images to include it.
ifeq (nats-bus, $(filter nats-bus,$(ARGS)))
  ARGS:=$(ARGS) dev app-dev device-dev
endif

ifeq (zero-trust, $(filter zero-trust,$(ARGS)))
	MAKE_ZERO_TRUST:=1
	export ZERO_TRUST_COMPOSE=-zero-trust
else
	MAKE_ZERO_TRUST:=0
	export ZERO_TRUST_COMPOSE=
endif
ifeq (no-cleanup, $(filter no-cleanup,$(ARGS)))
	NO_CLEANUP:=1
else
	NO_CLEANUP:=0
endif

ifeq (dev, $(filter dev,$(ARGS)))
	export CORE_EDGEX_REPOSITORY=edgexfoundry
	export CORE_EDGEX_VERSION=0.0.0-dev
	export DEV=-dev # require for the gateways scripts since they look for this
endif
ifeq (app-dev, $(filter app-dev,$(ARGS)))
	export APP_SVC_REPOSITORY=edgexfoundry
	export APP_SVC_DEV=-dev
	export APP_SERVICE_CONFIG_VERSION=0.0.0-dev
	export APP_LLRP_VERSION=0.0.0-dev
endif
ifeq (device-dev, $(filter device-dev,$(ARGS)))
	export DEVICE_SVC_REPOSITORY=edgexfoundry
	export DEVICE_BACNET_VERSION=0.0.0-dev
	export DEVICE_CAMERA_VERSION=0.0.0-dev
	export DEVICE_MODBUS_VERSION=0.0.0-dev
	export DEVICE_MQTT_VERSION=0.0.0-dev
	export DEVICE_REST_VERSION=0.0.0-dev
	export DEVICE_SNMP_VERSION=0.0.0-dev
	export DEVICE_VIRTUAL_VERSION=0.0.0-dev
	export DEVICE_LLRP_VERSION=0.0.0-dev
	export DEVICE_COAP_VERSION=0.0.0-dev
	export DEVICE_GPIO_VERSION=0.0.0-dev
	export DEVICE_ONVIFCAM_VERSION=0.0.0-dev
	export DEVICE_USBCAM_VERSION=0.0.0-dev
	export DEVICE_S7_VERSION=0.0.0-dev
endif
ifeq (ui-dev, $(filter ui-dev,$(ARGS)))
	export UI_REPOSITORY=edgexfoundry
	export EDGEX_UI_VERSION=0.0.0-dev
endif
ifeq (arm64, $(filter arm64,$(ARGS)))
	export ARCH=-arm64
else
	export ARCH=
endif

ifeq (mqtt-verbose, $(filter mqtt-verbose,$(ARGS)))
	export MQTT_VERBOSE=-v
else
    export MQTT_VERBOSE=
endif

ifeq (keeper, $(filter keeper,$(ARGS)))
	export CP_FLAGS='-cp=keeper.http://edgex-core-keeper:59890'
	export REGISTRY_HOST=edgex-core-keeper
	export REGISTRY_PORT=59890
	export REGISTRY_TYPE=keeper
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		export STAGEGATE_REGISTRY_HOST=edgex-core-keeper
		export STAGEGATE_REGISTRY_PORT=59890
	endif
endif

# When in delay-start mode, we have to make sure support serivces be delayed-start-compliant: i.e. the runtime-token configuration be added etc..
ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
	ext_file_sup_notif:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh support-notifications)
	ext_file_sup_sch:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh support-scheduler)
	COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file_sup_notif) -f $(ext_file_sup_sch)
endif

# Add Device Services
ifeq (ds-onvif-camera, $(filter ds-onvif-camera,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-onvif-camera.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-onvif-camera
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-onvif-camera
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-onvif-camera],message-bus[device-onvif-camera]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-onvif-camera],message-bus[device-onvif-camera]
		endif
		PROXY_ROUTE:=device-onvif-camera.http://edgex-device-onvif-camera:59984
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-onvif-camera)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-onvif-camera)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-usb-camera, $(filter ds-usb-camera,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-usb-camera.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-usb-camera
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-usb-camera
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-usb-camera],message-bus[device-usb-camera]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-usb-camera],message-bus[device-usb-camera]
		endif
		PROXY_ROUTE:=device-usb-camera.http://edgex-device-usb-camera:59983
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-usb-camera device-usb-camera docker-entrypoint.sh)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-usb-camera device-usb-camera docker-entrypoint.sh)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-bacnet-ip, $(filter ds-bacnet-ip,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-bacnet-ip.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-bacnet-ip
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-bacnet-ip
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-bacnet-ip],message-bus[device-bacnet-ip]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-bacnet-ip],message-bus[device-bacnet-ip]
		endif
		PROXY_ROUTE:=device-bacnet-ip.http://edgex-device-bacnet-ip:59980
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-bacnet-ip device-bacnet-ip device-bacnet-ip/device-bacnet-c " --registry ${CP_FLAGS}")

		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-bacnet-ip)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-bacnet-mstp, $(filter ds-bacnet-mstp,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-bacnet-mstp.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-bacnet-mstp
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-bacnet-mstp
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-bacnet-mstp],message-bus[device-bacnet-mstp]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-bacnet-mstp],message-bus[device-bacnet-mstp]
		endif
		PROXY_ROUTE:=device-bacnet-mstp.http://edgex-device-bacnet-mstp:59980
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-bacnet-mstp device-bacnet-mstp device-bacnet-mstp/device-bacnet-c " --registry ${CP_FLAGS}")

		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-bacnet-mstp)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-modbus, $(filter ds-modbus,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-modbus.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-modbus
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-modbus
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-modbus],message-bus[device-modbus]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-modbus],message-bus[device-modbus]
		endif
		PROXY_ROUTE:=device-modbus.http://edgex-device-modbus:59901
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-modbus)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-modbus)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-mqtt, $(filter ds-mqtt,$(ARGS)))
	ifeq (no-secty, $(filter no-secty,$(ARGS)))
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-mqtt.yml
	else
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-mqtt.yml -f add-secure-device-mqtt.yml
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-mqtt
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-mqtt
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-mqtt],message-bus[device-mqtt]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-mqtt],message-bus[device-mqtt]
		endif
		PROXY_ROUTE:=device-mqtt.http://edgex-device-mqtt:59982
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
			IS_MQTT_BUS:=1
		else
			IS_MQTT_BUS:=0
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" IS_MQTT_BUS="$(IS_MQTT_BUS)" ./gen_secure_compose_ext.sh device-mqtt)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-mqtt)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-rest, $(filter ds-rest,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-rest.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		# Device-rest's token is created by default, so not setting TOKEN_LIST
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-rest],message-bus[device-rest]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-rest],message-bus[device-rest]
		endif
		PROXY_ROUTE:=device-rest.http://edgex-device-rest:59986
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-rest)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-rest)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-snmp, $(filter ds-snmp,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-snmp.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-snmp
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-snmp
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-snmp],message-bus[device-snmp]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-snmp],message-bus[device-snmp]
		endif
		PROXY_ROUTE:=device-snmp.http://edgex-device-snmp:59993
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-snmp device-snmp device-snmp)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-snmp)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-virtual, $(filter ds-virtual,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-virtual.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		# Device-virtual's token is created by default, so not setting TOKEN_LIST
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-virtual],message-bus[device-virtual]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-virtual],message-bus[device-virtual]
		endif
		# Device-virtual's proxy is created by default, so not setting EXTRA_PROXY_ROUTE_LIST
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-virtual)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-virtual)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-llrp, $(filter ds-llrp,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-rfid-llrp.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-rfid-llrp
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-rfid-llrp
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-rfid-llrp],message-bus[device-rfid-llrp]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-rfid-llrp],message-bus[device-rfid-llrp]
		endif
		PROXY_ROUTE:=device-rfid-llrp.http://edgex-device-rfid-llrp:59989
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-rfid-llrp)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-rfid-llrp)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-coap, $(filter ds-coap,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-coap.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-coap
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-coap
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-coap],message-bus[device-coap]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-coap],message-bus[device-coap]
		endif
		PROXY_ROUTE:=device-coap.http://edgex-device-coap:59988
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-coap)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-coap)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-gpio, $(filter ds-gpio,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-gpio.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-gpio
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-gpio
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-gpio],message-bus[device-gpio]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-gpio],message-bus[device-gpio]
		endif
		PROXY_ROUTE:=device-gpio.http://edgex-device-gpio:59910
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-gpio)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-gpio)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-uart, $(filter ds-uart,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-uart.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-uart
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-uart
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-uart],message-bus[device-uart]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-uart],message-bus[device-uart]
		endif
		PROXY_ROUTE:=device-uart.http://edgex-device-uart:59995
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-uart)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-uart)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-s7, $(filter ds-s7,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-s7.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=device-s7
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-s7
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[device-s7],message-bus[device-s7]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-s7],message-bus[device-s7]
		endif
		PROXY_ROUTE:=device-s7.http://edgex-device-s7:59994
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-s7)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-s7)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
# Add ModBus Simulator
ifeq (modbus-sim, $(filter modbus-sim,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-modbus-simulator.yml
endif

# Add Application Services
ifeq (asc-http, $(filter asc-http,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-http-export.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=app-http-export
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-http-export
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[app-http-export],message-bus[app-http-export]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-http-export],message-bus[app-http-export]
		endif
		PROXY_ROUTE:=app-http-export.http://edgex-app-http-export:59704
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-http-export \
			app-http-export app-service-configurable)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-http-export)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (asc-mqtt, $(filter asc-mqtt,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-mqtt-export.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=app-mqtt-export
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-mqtt-export
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[app-mqtt-export],message-bus[app-mqtt-export]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-mqtt-export],message-bus[app-mqtt-export]
		endif
		ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
			IS_MQTT_BUS:=1
		else
			IS_MQTT_BUS:=0
		endif
		PROXY_ROUTE:=app-mqtt-export.http://edgex-app-mqtt-export:59703
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" IS_MQTT_BUS="$(IS_MQTT_BUS)" ./gen_secure_compose_ext.sh app-mqtt-export \
			app-mqtt-export app-service-configurable)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-mqtt-export)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (asc-sample, $(filter asc-sample,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-sample.yml
	APP_SAMPLE:=-with-app-sample
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=app-sample
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-sample
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[app-sample],message-bus[app-sample]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-sample],message-bus[app-sample]
		endif
		PROXY_ROUTE:=app-sample.http://edgex-app-sample:59700
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-sample \
			app-sample app-service-configurable)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-sample)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (asc-metrics, $(filter asc-metrics,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-metrics-influxdb.yml
	APP_METRICS:=-with-app-metrics-influxdb
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=app-metrics-influxdb
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-metrics-influxdb
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[app-metrics-influxdb],message-bus[app-metrics-influxdb]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-metrics-influxdb],message-bus[app-metrics-influxdb]
		endif
		PROXY_ROUTE:=app-metrics-influxdb.http://edgex-app-metrics-influxdb:59707
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-metrics-influxdb \
			app-metrics-influxdb app-service-configurable)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-metrics-influxdb)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (as-llrp, $(filter as-llrp,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-app-rfid-llrp-inventory.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=app-rfid-llrp-inventory
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-rfid-llrp-inventory
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[app-rfid-llrp-inventory],message-bus[app-rfid-llrp-inventory]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-rfid-llrp-inventory],message-bus[app-rfid-llrp-inventory]
		endif
		PROXY_ROUTE:=app-rfid-llrp-inventory.http://edgex-app-rfid-llrp-inventory:59711
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-rfid-llrp-inventory)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-rfid-llrp-inventory)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (as-record-replay, $(filter as-record-replay,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-app-record-replay.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=app-record-replay
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-record-replay
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=redisdb[app-record-replay],message-bus[app-record-replay]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-record-replay],message-bus[app-record-replay]
		endif
		PROXY_ROUTE:=app-record-replay.http://edgex-app-record-replay:59712
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-record-replay)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-record-replay)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif

ifeq (asc-ex-mqtt, $(filter asc-ex-mqtt,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-external-mqtt-trigger.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),)
			TOKEN_LIST:=app-external-mqtt-trigger
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-external-mqtt-trigger
		endif
		ifeq ($(KNOWN_SECRETS_LIST),)
			KNOWN_SECRETS_LIST:=message-bus[app-external-mqtt-trigger]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),message-bus[app-external-mqtt-trigger]
		endif
		ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
			IS_MQTT_BUS:=1
		else
			IS_MQTT_BUS:=0
		endif
		PROXY_ROUTE:=app-external-mqtt-trigger.http://edgex-app-external-mqtt-trigger:59706
		ifeq ($(EXTRA_PROXY_ROUTE_LIST),)
			EXTRA_PROXY_ROUTE_LIST:=$(PROXY_ROUTE)
		else
			EXTRA_PROXY_ROUTE_LIST:=$(EXTRA_PROXY_ROUTE_LIST),$(PROXY_ROUTE)
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" IS_MQTT_BUS="$(IS_MQTT_BUS)" ./gen_secure_compose_ext.sh app-external-mqtt-trigger \
			app-external-mqtt-trigger app-service-configurable)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-external-mqtt-trigger)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif

# Add delayed start services suppport (SPIFFE/SPIRE)
ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
	ifeq (no-secty, $(filter no-secty,$(ARGS)))
		ERR:=$(error Cannot specify both delayed-start and no-secty options)
	else
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-delayed-start-services.yml
	endif
endif

# Add a MQTT Broker
ifeq (mqtt-broker, $(filter mqtt-broker,$(ARGS)))
	ifeq (nanomq, $(filter nanomq,$(ARGS)))
		# When just extra un-secured MQTT Broker, nanomq can be used in secure/non-secure modes
		BROKER_YAML=add-mqtt-broker-nanomq.yml
	endif
	COMPOSE_FILES:=$(COMPOSE_FILES) -f ${BROKER_YAML}
endif

# Add switch to use MQTT Message Bus
ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	BUS:=-mqtt-bus
	ifeq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq (nanomq, $(filter nanomq,$(ARGS)))
			NANOMQ:=-nanomq
			COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-messagebus.yml -f add-mqtt-broker-nanomq.yml
		else
			COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-messagebus.yml -f add-mqtt-broker-mosquitto.yml
		endif
	else
		ifeq (nanomq, $(filter nanomq,$(ARGS)))
			ERR:=$(error nanomq option is not valid as MessageBus broker in secure mode)
		endif
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-messagebus.yml -f add-secure-mqtt-messagebus.yml -f add-mqtt-broker-mosquitto.yml -f add-secure-mqtt-broker.yml
	endif
endif

# Add switch to use NATS Message Bus
ifeq (nats-bus, $(filter nats-bus,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-nats-messagebus.yml
	BUS:=-nats-bus
endif

# Add Security services and settings
ifeq (no-secty, $(filter no-secty,$(ARGS)))
	NO_SECURITY:=-no-secty
else
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-security.yml
	ifeq ($(BUS),) # if BUS not set, then we are using secure redis messagebus by default
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-secure-redis-messagebus.yml
	endif
	# Add Security Proxy when not using zero-trust
	ifneq (zero-trust, $(filter zero-trust,$(ARGS)))
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-security-proxy.yml
	endif
endif

# Add switch to set registry
ifeq (keeper, $(filter keeper,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-keeper.yml
	REGISTRY:=-keeper
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
                COMPOSE_FILES:=$(COMPOSE_FILES) -f add-secure-keeper.yml
	endif
else
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-consul.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-secure-consul.yml
	endif
endif

# Build compose for TAF secure testing (ignore all other compose file options)
ifeq (taf-secty, $(filter taf-secty,$(ARGS)))
	TOKEN_LIST:=app-http-export,app-mqtt-export,app-functional-tests,app-scalability-test-mqtt-export,app-sample,device-modbus,app-external-mqtt-trigger,device-onvif-camera
	# Note that the services in this list should be separated by ';', but that causes issues with build scripts, so
	# have to list them individually.
	KNOWN_SECRETS_LIST:=redisdb[app-rules-engine],redisdb[app-http-export],redisdb[app-mqtt-export],redisdb[app-scalability-test-mqtt-export],redisdb[app-sample],redisdb[device-modbus],redisdb[device-rest],redisdb[device-virtual],redisdb[device-onvif-camera]
	KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),message-bus[app-rules-engine],message-bus[app-http-export],message-bus[app-mqtt-export],message-bus[app-external-mqtt-trigger],message-bus[app-scalability-test-mqtt-export],message-bus[app-sample],message-bus[device-modbus],message-bus[device-rest],message-bus[device-virtual],message-bus[device-onvif-camera]
	EXTRA_PROXY_ROUTE_LIST:=device-modbus.http://edgex-device-modbus:59901

	COMPOSE_FILES:= \
		-f docker-compose-base.yml \
		-f add-security.yml \
		-f add-security-proxy.yml \
		-f add-taf-app-services.yml \
		-f add-taf-app-services-secure.yml \
		-f add-asc-http-export.yml \
		-f add-asc-mqtt-export.yml \
		-f add-asc-external-mqtt-trigger.yml \
		-f add-asc-sample.yml \
		-f add-device-virtual.yml \
		-f add-device-rest.yml \
		-f add-device-modbus.yml \
		-f add-device-onvif-camera.yml \
		-f add-taf-device-services-mods.yml \
		-f add-mqtt-broker-mosquitto.yml \
		-f add-modbus-simulator.yml \
		-f add-delayed-start-services.yml \
		-f add-taf-mqtt-broker-mosquitto.yml \

	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
		IS_SECURE_MODE:=1
		IS_MQTT_BUS:=1
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-messagebus.yml -f add-secure-mqtt-messagebus.yml -f add-secure-mqtt-broker.yml
	else
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-secure-redis-messagebus.yml
		IS_MQTT_BUS:=0
	endif

	ifeq (keeper, $(filter keeper,$(ARGS)))
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-keeper.yml -f add-secure-keeper.yml
		REGISTRY:=-keeper
	else
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-consul.yml -f add-secure-consul.yml -f add-keeper.yml -f add-secure-keeper.yml
	endif

	asc_http_export_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)"  ./gen_secure_compose_ext.sh app-http-export \
		app-http-export app-service-configurable)
	asc_mqtt_export_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" IS_MQTT_BUS="$(IS_MQTT_BUS)" ./gen_secure_compose_ext.sh app-mqtt-export \
		app-mqtt-export app-service-configurable)
	scalability_mqtt_export_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" IS_MQTT_BUS="$(IS_MQTT_BUS)" ./gen_secure_compose_ext.sh app-scalability-test-mqtt-export \
		app-scalability-test-mqtt-export app-service-configurable)
	asc_external_mqtt_trigger_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" IS_MQTT_BUS="$(IS_MQTT_BUS)" ./gen_secure_compose_ext.sh app-external-mqtt-trigger \
		app-external-mqtt-trigger app-service-configurable)
	asc_sample_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-sample \
		app-sample app-service-configurable)
	ds_rest_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-rest)
	# taf has its special place holder from taf-device-services-mods and thus we need to keep it
	# and extend security related things on top of it
	ds_virtual_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-virtual \
		device-virtual device-virtual " ${CP_FLAGS} --configDir=CONFIG_DIR_PLACE_HOLDER")
	ds_modbus_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-modbus \
		device-modbus device-modbus " ${CP_FLAGS} --configDir=CONFIG_DIR_PLACE_HOLDER")
	ds_camera_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-onvif-camera)
	COMPOSE_FILES:=$(COMPOSE_FILES) -f $(asc_http_export_ext) -f $(asc_mqtt_export_ext) -f $(asc_external_mqtt_trigger_ext) -f $(scalability_mqtt_export_ext) -f $(asc_sample_ext)
	COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ds_virtual_ext) -f $(ds_rest_ext) -f $(ds_modbus_ext) -f $(ds_camera_ext)
else
	ifeq (nanomq, $(filter nanomq,$(ARGS)))
		BROKER_YAML=add-mqtt-broker-nanomq.yml
		TAF_BROKER_YAML=add-taf-mqtt-broker-nanomq.yml
	endif

	# Build compose for TAF non-secure testing (ignore all other compose file options)
    ifeq (taf-no-secty, $(filter taf-no-secty,$(ARGS)))

		COMPOSE_FILES:= \
			-f docker-compose-base.yml \
			-f add-taf-app-services.yml \
			-f add-asc-http-export.yml \
			-f add-asc-mqtt-export.yml \
			-f add-asc-external-mqtt-trigger.yml \
			-f add-asc-sample.yml \
			-f add-device-virtual.yml \
			-f add-device-rest.yml \
			-f add-device-modbus.yml \
            -f add-device-onvif-camera.yml \
			-f add-taf-device-services-mods.yml \
			-f ${BROKER_YAML} \
			-f add-modbus-simulator.yml \
			-f ${TAF_BROKER_YAML}

        NO_SECURITY:=-no-secty

        ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
            IS_SECURE_MODE:=0
            COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-messagebus.yml
        endif

		ifeq (keeper, $(filter keeper,$(ARGS)))
			COMPOSE_FILES:=$(COMPOSE_FILES) -f add-keeper.yml
			REGISTRY:=-keeper
		else
			COMPOSE_FILES:=$(COMPOSE_FILES) -f add-consul.yml -f add-keeper.yml
		endif
    else
    	# Build compose for TAF secure performance testing (ignore all other compose file options)
    	ifeq (taf-perf, $(filter taf-perf,$(ARGS)))
			TOKEN_LIST:=app-http-export,app-mqtt-export,app-functional-tests,app-scalability-test-mqtt-export
			# Note that the services in this list should be separated by ';', but that causes issues with build scripts, so
			# have to list them individually.
			KNOWN_SECRETS_LIST:=redisdb[app-rules-engine],redisdb[app-http-export],redisdb[app-mqtt-export],redisdb[app-scalability-test-mqtt-export],redisdb[device-rest],redisdb[device-virtual]
			EXTRA_PROXY_ROUTE_LIST:=device-modbus.http://edgex-device-modbus:59901

    		COMPOSE_FILES:= \
				-f docker-compose-base.yml \
				-f add-security.yml \
				-f add-security-proxy.yml \
				-f add-secure-redis-messagebus.yml \
				-f add-asc-mqtt-export.yml \
				-f add-device-virtual.yml \
				-f add-device-rest.yml \
				-f add-mqtt-broker-mosquitto.yml \
				-f add-taf-mqtt-broker-mosquitto.yml \
				-f add-delayed-start-services.yml

			ifeq (keeper, $(filter keeper,$(ARGS)))
				COMPOSE_FILES:=$(COMPOSE_FILES) -f add-keeper.yml -f add-secure-keeper.yml
				REGISTRY:=-keeper
			else
				COMPOSE_FILES:=$(COMPOSE_FILES) -f add-consul.yml -f add-secure-consul.yml
			endif

			asc_mqtt_export_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)"  IS_MQTT_BUS="0" ./gen_secure_compose_ext.sh app-mqtt-export \
				app-mqtt-export app-service-configurable)
			ds_virtual_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-virtual)
			ds_rest_ext:= $(shell ZERO_TRUST="$(MAKE_ZERO_TRUST)" GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-rest)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(asc_mqtt_export_ext) -f $(ds_virtual_ext) -f $(ds_rest_ext)
    	else
			# Build compose for TAF non-secure performance testing (ignore all other compose file options)
			ifeq (taf-perf-no-secty, $(filter taf-perf-no-secty,$(ARGS)))
				COMPOSE_FILES:= \
					-f docker-compose-base.yml \
					-f add-asc-mqtt-export.yml \
					-f add-device-virtual.yml \
					-f add-device-rest.yml \
					-f ${BROKER_YAML} \
					-f ${TAF_BROKER_YAML}

				ifeq (keeper, $(filter keeper,$(ARGS)))
					COMPOSE_FILES:=$(COMPOSE_FILES) -f add-keeper.yml
					REGISTRY:=-keeper
				else
					COMPOSE_FILES:=$(COMPOSE_FILES) -f add-consul.yml
				endif
				NO_SECURITY:=-no-secty
			endif
		endif
	endif
endif

SERVICES:=$(filter-out ${OPTIONS},$(ARGS))

export TOKEN_LIST
export KNOWN_SECRETS_LIST
export EXTRA_PROXY_ROUTE_LIST
export GEN_EXT_DIR
export SPIFFE_TRUSTDOMAIN
export SPIFFE_ENDPOINTSOCKET

define COMPOSE_DOWN
	${DOCKER_COMPOSE} -p edgex \
		-f docker-compose-base.yml \
		-f add-device-bacnet-ip.yml \
		-f add-device-bacnet-mstp.yml \
		-f add-device-onvif-camera.yml \
		-f add-device-usb-camera.yml \
		-f add-device-modbus.yml \
		-f add-device-mqtt.yml \
		-f add-secure-device-mqtt.yml \
		-f add-device-rest.yml \
		-f add-device-snmp.yml \
		-f add-device-coap.yml \
		-f add-device-gpio.yml \
		-f add-device-uart.yml \
		-f add-device-rfid-llrp.yml \
		-f add-device-virtual.yml \
		-f add-device-s7.yml \
		-f add-asc-http-export.yml \
		-f add-asc-mqtt-export.yml \
		-f add-asc-external-mqtt-trigger.yml \
		-f add-asc-sample.yml \
		-f add-asc-metrics-influxdb.yml \
		-f add-app-rfid-llrp-inventory.yml \
		-f add-app-record-replay.yml \
		-f add-modbus-simulator.yml \
		-f add-mqtt-broker-mosquitto.yml \
		-f add-secure-mqtt-broker.yml \
		-f add-mqtt-messagebus.yml \
		-f add-secure-mqtt-messagebus.yml \
		-f add-nats-messagebus.yml \
		-f add-security.yml \
		-f add-security-proxy.yml \
		-f add-secure-redis-messagebus.yml \
		-f add-delayed-start-services.yml \
		-f add-consul.yml \
		-f add-secure-consul.yml \
		-f add-keeper.yml \
		-f add-secure-keeper.yml \
		down $1
endef

ifeq (zero-trust, $(filter zero-trust,$(ARGS)))
	# overrides for zero trust from the base files
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-security-zero-trust.yml
endif

docker_ver:= $(shell ${DOCKER_COMPOSE} version)

# Define additional phony targets for all options to enable support for tab-completion in shell
# Note: This must be defined after the options are parsed otherwise it will interfere with them
.PHONY: $(OPTIONS)

help:
	echo "See README.md in this folder"

portainer:
	make -C ${RELEASE_FOLDER} portainer

portainer-down:
	make -C ${RELEASE_FOLDER} portainer-down

build: build-canned build-taf

build-canned:
	make compose ds-rest ds-virtual
	make compose ds-rest ds-virtual arm64
	make compose ds-rest ds-virtual asc-sample
	make compose ds-rest ds-virtual asc-sample arm64
	make compose ds-rest ds-virtual no-secty
	make compose ds-rest ds-virtual no-secty arm64
	make compose ds-rest ds-virtual asc-sample no-secty
	make compose ds-rest ds-virtual asc-sample no-secty arm64
	make compose ds-rest ds-virtual zero-trust
	make compose ds-rest ds-virtual zero-trust arm64

build-taf:
	make taf-compose taf-secty
	make taf-compose taf-no-secty
	make taf-compose taf-secty arm64
	make taf-compose taf-no-secty arm64
	make taf-compose taf-secty mqtt-bus mqtt-verbose
	make taf-compose taf-no-secty mqtt-bus mqtt-verbose
	make taf-compose taf-secty mqtt-bus mqtt-verbose arm64
	make taf-compose taf-no-secty mqtt-bus mqtt-verbose arm64
	make taf-compose taf-secty keeper
	make taf-compose taf-no-secty keeper
	make taf-compose taf-secty keeper arm64
	make taf-compose taf-no-secty keeper arm64
	make taf-compose taf-secty keeper mqtt-bus mqtt-verbose
	make taf-compose taf-no-secty keeper mqtt-bus mqtt-verbose
	make taf-compose taf-secty keeper mqtt-bus mqtt-verbose arm64
	make taf-compose taf-no-secty keeper mqtt-bus mqtt-verbose arm64
	make taf-compose-perf taf-perf
	make taf-compose-perf taf-perf-no-secty
	make taf-compose-perf taf-perf arm64
	make taf-compose-perf taf-perf-no-secty arm64

build-taf-nanomq:
	make taf-compose taf-no-secty mqtt-bus nanomq no-secty
	make taf-compose taf-no-secty keeper mqtt-bus nanomq no-secty
	make taf-compose-perf taf-perf-no-secty mqtt-bus nanomq no-secty
	make taf-compose-perf taf-perf-no-secty consul mqtt-bus nanomq no-secty

compose: gen
	cat gen-header docker-compose.yml > $(RELEASE_FOLDER)/docker-compose$(NO_SECURITY)$(APP_SAMPLE)$(BUS)$(NANOMQ)$(ZERO_TRUST_COMPOSE)$(ARCH).yml

taf-compose: gen
	cat gen-header docker-compose.yml > $(RELEASE_FOLDER)/taf/docker-compose-taf$(NO_SECURITY)$(BUS)$(NANOMQ)$(REGISTRY)$(ARCH).yml

taf-compose-perf: gen
	cat gen-header docker-compose.yml > $(RELEASE_FOLDER)taf/docker-compose-taf-perf$(NO_SECURITY)$(BUS)$(NANOMQ)$(ARCH).yml

run: gen
	${DOCKER_COMPOSE}  -p edgex up -d $(SERVICES)

pull: gen
	${DOCKER_COMPOSE}  pull $(SERVICES)

gen:
	echo MQTT_VERBOSE=${MQTT_VERBOSE}
	${DOCKER_COMPOSE}  -p edgex $(COMPOSE_FILES) ${GEN_COMMAND} --output docker-compose.yml.gen
	if [ "$(NO_CLEANUP)" = "0" ]; then rm -rf ./$(GEN_EXT_DIR); fi
	echo "# Generated with: $(docker_ver)" > docker-compose.yml
	cat docker-compose.yml.gen >> docker-compose.yml
	rm docker-compose.yml.gen
	
get-token:
	sh ./get-api-gateway-token.sh

upload-tls-cert:
	sh ./upload-api-gateway-cert.sh

get-consul-acl-token:
	sh ./get-consul-acl-token.sh

up:
	${DOCKER_COMPOSE}  -p edgex -f docker-compose.yml up -d

down:
	$(COMPOSE_DOWN)

clean:
	$(call COMPOSE_DOWN,-v)

err: ; $(ERR)

args:
	echo $(ARGS)
	echo $(CORE_EDGEX_REPOSITORY)
	echo $(CORE_EDGEX_VERSION)
