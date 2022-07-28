# /*******************************************************************************
#  * Copyright 2022 Intel
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
    down clean err
.SILENT: help get-token del-token upload-tls-cert get-consul-acl-token

include .env
include common-security.env

COMPOSE_FILES:=-f docker-compose-base.yml
TOKEN_LIST:=""
KNOWN_SECRETS_LIST:="redisdb[app-rules-engine]"
EXTRA_PROXY_ROUTE_LIST:=""
GEN_EXT_DIR:=gen_ext_compose

# Must have spaces around words for `filter-out` function to work properly.
# Dashes at beginning & end of line ensure space before/after the first/last option on that line
# and don't impact the option list
define OPTIONS
 - arm64 no-secty dev app-dev delayed-start -
 - zmq-bus mqtt-bus mqtt-broker -
 - taf-secty taf-no-secty taf-perf taf-perf-no-secty -
 - ds-onvif-camera  ds-usb-camera ds-bacnet ds-camera ds-grove ds-modbus ds-mqtt ds-rest ds-snmp ds-virtual ds-llrp ds-coap ds-gpio -
 - asc-http asc-mqtt asc-sample asc-metrics as-llrp asc-ex-mqtt -
 - modbus-sim -
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
	APP_SERVICE_CONFIG_VERSION:="0.0.0"
endif
ifeq (arm64, $(filter arm64,$(ARGS)))
	ARCH:=-arm64
	KONG_UBUNTU:=-ubuntu
endif

# Add Device Services
ifeq (ds-onvif-camera, $(filter ds-onvif-camera,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-onvif-camera.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-onvif-camera -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-onvif-camera
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-onvif-camera
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-onvif-camera]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-onvif-camera]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-onvif-camera)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-onvif-camera)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-usb-camera, $(filter ds-usb-camera,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-usb-camera.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-usb-camera -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-usb-camera
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-usb-camera
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-usb-camera]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-usb-camera]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-usb-camera)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-usb-camera)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-bacnet, $(filter ds-bacnet,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-bacnet.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-bacnet -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-bacnet
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-bacnet
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-bacnet]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-bacnet]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-bacnet device-bacnet startup.sh "")
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-bacnet)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-camera, $(filter ds-camera,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-camera.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-camera -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-camera
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-camera
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-camera]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-camera]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-camera)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-camera)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-grove, $(filter ds-grove,$(ARGS)))
    DS_GROVE:=true
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-grove.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-grove -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-grove
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-grove
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-grove]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-grove]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-grove)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-grove)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-modbus, $(filter ds-modbus,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-modbus.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-modbus -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-modbus
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-modbus
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-modbus]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-modbus]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-modbus)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-modbus)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-mqtt, $(filter ds-mqtt,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-mqtt.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-mqtt -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-mqtt
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-mqtt
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-mqtt]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-mqtt]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-mqtt)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-mqtt)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-rest, $(filter ds-rest,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-rest.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-rest -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-rest]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-rest]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-rest)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-rest)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-snmp, $(filter ds-snmp,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-snmp.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-snmp -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-snmp
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-snmp
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-snmp]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-snmp]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-snmp device-snmp-go device-snmp-go)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-snmp)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-virtual, $(filter ds-virtual,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-virtual.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-virtual -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		# Device-virtual's token is created by default.
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-virtual]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-virtual]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-virtual)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-virtual)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-llrp, $(filter ds-llrp,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-rfid-llrp.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-rfid-llrp -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-rfid-llrp
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-rfid-llrp
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-rfid-llrp]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-rfid-llrp]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-rfid-llrp)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-rfid-llrp)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-coap, $(filter ds-coap,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-coap.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-coap -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-coap
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-coap
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-coap]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-coap]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-coap)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-coap)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (ds-gpio, $(filter ds-gpio,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-device-gpio.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-gpio -d)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=device-gpio
		else
			TOKEN_LIST:=$(TOKEN_LIST),device-gpio
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[device-gpio]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[device-gpio]
		endif
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-gpio)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh device-gpio)
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
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh app-service-http-export -a)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=app-http-export
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-http-export
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[app-http-export]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-http-export]
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-service-http-export \
			app-http-export app-service-configurable)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-service-http-export)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (asc-mqtt, $(filter asc-mqtt,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-mqtt-export.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh app-service-mqtt-export -a)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=app-mqtt-export
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-mqtt-export
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[app-mqtt-export]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-mqtt-export]
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-service-mqtt-export \
			app-mqtt-export app-service-configurable)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-service-mqtt-export)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (asc-sample, $(filter asc-sample,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-sample.yml
	APP_SAMPLE:=-with-app-sample
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh app-service-sample -a)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=app-sample
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-sample
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[app-sample]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-sample]
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-service-sample \
			app-sample app-service-configurable)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-service-sample)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (asc-metrics, $(filter asc-metrics,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-metrics-influxdb.yml
	APP_METRICS:=-with-app-metrics-influxdb
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh app-metrics-influxdb -a)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=app-metrics-influxdb
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-metrics-influxdb
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[app-metrics-influxdb]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-metrics-influxdb]
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-metrics-influxdb \
			app-metrics-influxdb app-service-configurable)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-metrics-influxdb)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (as-llrp, $(filter as-llrp,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-app-rfid-llrp-inventory.yml
	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	  extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh app-rfid-llrp-inventory -a)
	  COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
	endif
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=app-rfid-llrp-inventory
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-rfid-llrp-inventory
		endif
		ifeq ($(KNOWN_SECRETS_LIST),"")
			KNOWN_SECRETS_LIST:=redisdb[app-rfid-llrp-inventory]
		else
			KNOWN_SECRETS_LIST:=$(KNOWN_SECRETS_LIST),redisdb[app-rfid-llrp-inventory]
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-rfid-llrp-inventory)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-rfid-llrp-inventory)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ext_file)
		endif
	endif
endif
ifeq (asc-ex-mqtt, $(filter asc-external-mqtt-trigger,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-asc-external-mqtt-trigger.yml
	ifneq (no-secty, $(filter no-secty,$(ARGS)))
		ifeq ($(TOKEN_LIST),"")
			TOKEN_LIST:=app-external-mqtt-trigger
		else
			TOKEN_LIST:=$(TOKEN_LIST),app-external-mqtt-trigger
		endif
		# when no security mode (no-secty) not explicitly specified,
		# then we also need to add the secure version on top of base yml by default.
		extension_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-service-external-mqtt-trigger \
			app-external-mqtt-trigger app-service-configurable)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(extension_file)
		# add runtime token config for delayed-start if specified
		ifeq (delayed-start, $(filter delayed-start,$(ARGS)))
			ext_file:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_runtime_token_config_compose_ext.sh app-service-external-mqtt-trigger)
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
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-broker.yml
endif

# Add switch to use MQTT Message Bus
ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-messagebus.yml -f add-mqtt-broker.yml
	BUS:=-mqtt-bus
endif

# Add switch to use ZMQ Message Bus
ifeq (zmq-bus, $(filter zmq-bus,$(ARGS)))
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-zmq-messagebus.yml
	BUS:=-zmq-bus
endif

# Add Security services and settings
ifeq (no-secty, $(filter no-secty,$(ARGS)))
	NO_SECURITY:=-no-secty
else
	COMPOSE_FILES:=$(COMPOSE_FILES) -f add-security.yml
	ifneq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
		ifneq (zmq-bus, $(filter zmq-bus,$(ARGS)))
		    # Using secure redis messagebus by default if MQTT/ZMQ bus not specified
			COMPOSE_FILES:=$(COMPOSE_FILES) -f add-secure-redis-messagebus.yml
		endif
	endif
endif

# Build compose for TAF secure testing (ignore all other compose file options)
ifeq (taf-secty, $(filter taf-secty,$(ARGS)))
	TOKEN_LIST:=app-http-export,app-mqtt-export,app-functional-tests,scalability-test-mqtt-export,device-modbus,app-external-mqtt-trigger,device-camera
	# Note that the services in this list should be separated by ';', but that causes issues with build scripts, so
	# have to list them individually.
	KNOWN_SECRETS_LIST:=redisdb[app-rules-engine],redisdb[app-http-export],redisdb[app-mqtt-export],redisdb[scalability-test-mqtt-export],redisdb[device-modbus],redisdb[device-rest],redisdb[device-virtual],redisdb[device-camera]
	EXTRA_PROXY_ROUTE_LIST:=device-modbus.http://edgex-device-modbus:59901

	COMPOSE_FILES:= \
		-f docker-compose-base.yml \
		-f add-security.yml \
		-f add-taf-app-services.yml \
		-f add-taf-app-services-secure.yml \
		-f add-asc-http-export.yml \
		-f add-asc-mqtt-export.yml \
		-f add-asc-external-mqtt-trigger.yml \
		-f add-device-virtual.yml \
		-f add-device-rest.yml \
		-f add-device-modbus.yml \
        -f add-device-camera.yml \
		-f add-taf-device-services-mods.yml \
		-f add-mqtt-broker.yml \
		-f add-modbus-simulator.yml \

	ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
		asc_http_export_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh app-service-http-export -a)
		asc_mqtt_export_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh app-service-mqtt-export -a)
		scalability_mqtt_export_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh scalability-test-mqtt-export -a)
		ds_rest_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-rest -d)
		ds_virtual_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-virtual -d)
		ds_modbus_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-modbus -d)
		ds_camera_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-camera -d)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-messagebus.yml
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(asc_http_export_ext) -f $(asc_mqtt_export_ext) -f $(scalability_mqtt_export_ext)
		COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ds_virtual_ext) -f $(ds_rest_ext) -f $(ds_modbus_ext) -f $(ds_camera_ext)
	else
		COMPOSE_FILES:=$(COMPOSE_FILES) -f add-secure-redis-messagebus.yml
	endif

	asc_http_export_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-service-http-export \
		app-http-export app-service-configurable)
	asc_mqtt_export_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-service-mqtt-export \
		app-mqtt-export app-service-configurable)
	asc_external_mqtt_trigger_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-service-external-mqtt-trigger \
		app-external-mqtt-trigger app-service-configurable)
	ds_rest_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-rest)
	# taf has its special place holder from taf-device-services-mods and thus we need to keep it
	# and extend security related things on top of it
	ds_virtual_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-virtual \
		device-virtual device-virtual ' -cp=consul.http:\/\/edgex-core-consul:8500 --registry --confdir=CONF_DIR_PLACE_HOLDER')
	ds_modbus_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-modbus \
		device-modbus device-modbus ' -cp=consul.http:\/\/edgex-core-consul:8500 --registry --confdir=CONF_DIR_PLACE_HOLDER')
	ds_camera_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-camera)
	COMPOSE_FILES:=$(COMPOSE_FILES) -f $(asc_http_export_ext) -f $(asc_mqtt_export_ext) -f $(asc_external_mqtt_trigger_ext)
	COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ds_virtual_ext) -f $(ds_rest_ext) -f $(ds_modbus_ext) -f $(ds_camera_ext)
else
	# Build compose for TAF non-secure testing (ignore all other compose file options)
    ifeq (taf-no-secty, $(filter taf-no-secty,$(ARGS)))
		COMPOSE_FILES:= \
			-f docker-compose-base.yml \
			-f add-taf-app-services.yml \
			-f add-asc-http-export.yml \
			-f add-asc-mqtt-export.yml \
			-f add-asc-external-mqtt-trigger.yml \
			-f add-device-virtual.yml \
			-f add-device-rest.yml \
			-f add-device-modbus.yml \
            -f add-device-camera.yml \
			-f add-taf-device-services-mods.yml \
			-f add-mqtt-broker.yml \
			-f add-modbus-simulator.yml
        NO_SECURITY:=-no-secty

        ifeq (mqtt-bus, $(filter mqtt-bus,$(ARGS)))
            asc_http_export_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh app-service-http-export -a)
            asc_mqtt_export_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh app-service-mqtt-export -a)
            scalability_mqtt_export_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh scalability-test-mqtt-export -a)
            ds_rest_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-rest -d)
            ds_virtual_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-virtual -d)
            ds_modbus_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-modbus -d)
            ds_camera_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_mqtt_messagebus_compose_ext.sh device-camera -d)
            COMPOSE_FILES:=$(COMPOSE_FILES) -f add-mqtt-messagebus.yml
            COMPOSE_FILES:=$(COMPOSE_FILES) -f $(asc_http_export_ext) -f $(asc_mqtt_export_ext) -f $(scalability_mqtt_export_ext)
            COMPOSE_FILES:=$(COMPOSE_FILES) -f $(ds_virtual_ext) -f $(ds_rest_ext) -f $(ds_modbus_ext) -f $(ds_camera_ext)
        endif
    else
    	# Build compose for TAF secure performance testing (ignore all other compose file options)
    	ifeq (taf-perf, $(filter taf-perf,$(ARGS)))
			TOKEN_LIST:=app-http-export,app-mqtt-export,app-functional-tests,scalability-test-mqtt-export
			# Note that the services in this list should be separated by ';', but that causes issues with build scripts, so
			# have to list them individually.
			KNOWN_SECRETS_LIST:=redisdb[app-rules-engine],redisdb[app-http-export],redisdb[app-mqtt-export],redisdb[scalability-test-mqtt-export],redisdb[device-rest],redisdb[device-virtual]
			EXTRA_PROXY_ROUTE_LIST:=device-modbus.http://edgex-device-modbus:59901

    		COMPOSE_FILES:= \
    			-f docker-compose-base.yml \
    			-f add-security.yml \
    			-f add-secure-redis-messagebus.yml \
    			-f add-asc-mqtt-export.yml \
    			-f add-device-virtual.yml \
    			-f add-device-rest.yml \
    			-f add-mqtt-broker.yml
			asc_mqtt_export_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh app-service-mqtt-export \
				app-mqtt-export app-service-configurable)
			ds_virtual_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-virtual)
			ds_rest_ext:= $(shell GEN_EXT_DIR="$(GEN_EXT_DIR)" ./gen_secure_compose_ext.sh device-rest)
			COMPOSE_FILES:=$(COMPOSE_FILES) -f $(asc_mqtt_export_ext) -f $(ds_virtual_ext) -f $(ds_rest_ext)
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

define COMPOSE_DOWN
	DEV= \
	APP_SVC_DEV= \
	ARCH= \
	TOKEN_LIST= \
	KNOWN_SECRETS_LIST= \
	EXTRA_PROXY_ROUTE_LIST= \
	docker-compose -p edgex \
		-f docker-compose-base.yml \
		-f add-device-bacnet.yml \
		-f add-device-camera.yml \
		-f add-device-onvif-camera.yml \
		-f add-device-usb-camera.yml \
		-f add-device-grove.yml \
		-f add-device-modbus.yml \
		-f add-device-mqtt.yml \
		-f add-device-rest.yml \
		-f add-device-snmp.yml \
		-f add-device-coap.yml \
		-f add-device-gpio.yml \
		-f add-device-rfid-llrp.yml \
		-f add-device-virtual.yml \
		-f add-asc-http-export.yml \
		-f add-asc-mqtt-export.yml \
		-f add-asc-sample.yml \
		-f add-asc-metrics-influxdb.yml \
		-f add-app-rfid-llrp-inventory.yml \
		-f add-modbus-simulator.yml \
		-f add-mqtt-broker.yml \
		-f add-mqtt-messagebus.yml \
		-f add-security.yml \
		-f add-secure-redis-messagebus.yml \
		-f add-delayed-start-services.yml \
		down $1
endef

# Define additional phony targets for all options to enable support for tab-completion in shell
# Note: This must be defined after the options are parsed otherwise it will interfere with them
.PHONY: $(OPTIONS)

help:
	echo "See README.md in this folder"

portainer:
	make -C ${RELEASE_FOLDER} portainer

portainer-down:
	make -C ${RELEASE_FOLDER} portainer-down

build:
	make compose ds-rest ds-virtual
	make compose ds-rest ds-virtual arm64
	make compose ds-rest ds-virtual asc-sample
	make compose ds-rest ds-virtual asc-sample arm64
	make compose ds-rest ds-virtual no-secty
	make compose ds-rest ds-virtual no-secty arm64
	make compose ds-rest ds-virtual asc-sample no-secty
	make compose ds-rest ds-virtual asc-sample no-secty arm64
	make taf-compose taf-secty
	make taf-compose taf-no-secty
	make taf-compose taf-secty arm64
	make taf-compose taf-no-secty arm64
	make taf-compose taf-secty mqtt-bus
	make taf-compose taf-no-secty mqtt-bus
	make taf-compose taf-secty mqtt-bus arm64
	make taf-compose taf-no-secty mqtt-bus arm64
	make taf-compose-perf taf-perf
	make taf-compose-perf taf-perf-no-secty
	make taf-compose-perf taf-perf arm64
	make taf-compose-perf taf-perf-no-secty arm64

compose: gen
	cat gen-header docker-compose.yml > $(RELEASE_FOLDER)/docker-compose$(NO_SECURITY)$(APP_SAMPLE)$(BUS)$(ARCH).yml

taf-compose: gen
	cat gen-header docker-compose.yml > $(RELEASE_FOLDER)/taf/docker-compose-taf$(NO_SECURITY)$(BUS)$(ARCH).yml

taf-compose-perf: gen
	cat gen-header docker-compose.yml > $(RELEASE_FOLDER)/taf/docker-compose-taf-perf$(NO_SECURITY)$(BUS)$(ARCH).yml

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
	APP_SERVICE_CONFIG_VERSION=$(APP_SERVICE_CONFIG_VERSION) \
	ARCH=$(ARCH) \
	TOKEN_LIST=$(TOKEN_LIST) \
	KNOWN_SECRETS_LIST=$(KNOWN_SECRETS_LIST) \
	EXTRA_PROXY_ROUTE_LIST=$(EXTRA_PROXY_ROUTE_LIST) \
	GEN_EXT_DIR=$(GEN_EXT_DIR) \
	SPIFFE_TRUSTDOMAIN=$(SPIFFE_TRUSTDOMAIN) \
	SPIFFE_ENDPOINTSOCKET=$(SPIFFE_ENDPOINTSOCKET) \
	docker-compose -p edgex $(COMPOSE_FILES) config > docker-compose.yml
	rm -rf ./$(GEN_EXT_DIR)

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

down:
	$(COMPOSE_DOWN)

clean:
	$(call COMPOSE_DOWN,-v)

err: ; $(ERR)
