#!/bin/sh
# /*******************************************************************************
#  * Copyright 2021 Intel Corporation.
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
#  *******************************************************************************/

# This shell script is used to generate the docker-compose yaml file.
# It scans the make command arguments and generating the related services in secure mode dynamically
# if found any; and it produces a docker-compose file that contains all servcies included in ARGS list.
# If there is a "no-secty" as part of make command arguments, then it just generates the compose file
# as it is from the ARGS list.

. ./.env

if [ "$DEV" = "-dev" ]; then
  CORE_EDGEX_REPOSITORY=edgexfoundry
  CORE_EDGEX_VERSION=0.0.0
fi

# function to append an input argument to an existing environment variable, TOKEN_LIST
append_token_list()
{
    appendee=$1
    if [ "$TOKEN_LIST" = "" ]; then
        TOKEN_LIST="$appendee"
        return
    fi

    TOKEN_LIST="$TOKEN_LIST,$appendee"
}

# function to set up device-services replacement environment variable values based on make input argument $1
setup_device_replacement_env_values()
{
    service=$1
    isAppendToken=$2

    pattern="ds-"
    replacement="device-"
    # replace pattern with replacement
    SERVICE_NAME=$(echo "$service" | sed 's/'"$pattern"'/'"$replacement"'/g')
    SERVICE_KEY=$(echo "$service" | sed 's/'"$pattern"'/'"$replacement"'/g')
    if [ "$isAppendToken" = "true" ]; then
        append_token_list $SERVICE_KEY
    fi
}

if [ ! "$NO_SECURITY" = "" ]; then
    echo "generating compose file for no-security mode"
    docker-compose -p edgex ${COMPOSE_FILES} config > docker-compose.yml
    return
fi

# temporarily directory to generate individual yml file
STAGING_DIR="gen_staging"

ADD_SERVICE_SECURE_FILE_TEMPLATE="add-service-secure-template.yml"

# loop through to determine whether to cleanup the temporary directory? 
# we may not want to clean up the temporary compose file directory until compose down
for arg in "$@"; do
    case "$arg" in 
    no-delete)
        NO_DELETE="true"
        break
        ;;
    *)
        NO_DELETE="false"
        ;;
    esac
done

if [ "$NO_DELETE" != "true" ]; then
    rm -rf "$STAGING_DIR"
    mkdir -p "$STAGING_DIR"
else
    echo "keep staging directory"
fi

for arg in "$@"; do

    case "$arg" in
    compose-down)
        # generate everything so that it can be found in compose-down
        COMPOSE_FILES="-f docker-compose-base.yml -f add-security.yml -f add-device-bacnet.yml -f add-device-camera.yml"
        COMPOSE_FILES="$COMPOSE_FILES -f add-device-grove.yml -f add-device-modbus.yml -f add-device-mqtt.yml"
        COMPOSE_FILES="$COMPOSE_FILES -f add-device-random.yml -f add-device-rest.yml -f add-device-snmp.yml -f add-device-virtual.yml"
        COMPOSE_FILES="$COMPOSE_FILES -f add-asc-http-export.yml -f add-asc-mqtt-export.yml"
        COMPOSE_FILES="$COMPOSE_FILES -f add-modbus-simulator.yml -f add-mqtt-broker.yml -f add-mqtt-messagebus.yml"
        ./gen_compose.sh no-delete asc-http asc-mqtt \
            ds-bacnet ds-camera ds-grove ds-modbus ds-mqtt ds-random ds-rest ds-virtual
        
        # temporarily create a list of file
        tmp_compose_file="$STAGING_DIR"/compose_file_list
        ls "$STAGING_DIR"/*.yml > "$tmp_compose_file"
        while read -r composefile ; do
            COMPOSE_FILES="$COMPOSE_FILES -f $composefile"
        done < "$tmp_compose_file"
        docker-compose -p edgex $COMPOSE_FILES down || true
        # cleanup
        rm -rf "$STAGING_DIR"
        # we are done here
        exit 0
        ;;
    asc-http)
        SERVICE_NAME="app-service-http-export"
        SERVICE_KEY="app-http-export"
        append_token_list $SERVICE_KEY
        COMMAND="\/app-service-configurable "'${DEFAULT_EDGEX_RUN_CMD_PARMS}'
        ;;
    asc-mqtt)
        SERVICE_NAME="app-service-mqtt-export"
        SERVICE_KEY="app-mqtt-export"
        append_token_list $SERVICE_KEY
        COMMAND="\/app-service-configurable "'${DEFAULT_EDGEX_RUN_CMD_PARMS}'
        ENV_SECTION='environment:\r      WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_AUTHMODE : usernamepassword\r      WRITABLE_INSECURESECRETS_MQTT_SECRETS_USERNAME: USERNAME_PLACEH_OLDER\r      WRITABLE_INSECURESECRETS_MQTT_SECRETS_PASSWORD: PASSWORD_PLACE_HOLDER'
        ;;
    ds-bacnet)
        setup_device_replacement_env_values "ds-bacnet" "true"
        COMMAND="\/startup.sh"
        ;;
    ds-camera)
        setup_device_replacement_env_values "ds-camera" "true"
        COMMAND="\/device-camera-go "'${DEFAULT_EDGEX_RUN_CMD_PARMS}'
        ;;
    ds-grove)
        setup_device_replacement_env_values "ds-grove" "true"
        COMMAND="\/device-grove "'${DEFAULT_EDGEX_RUN_CMD_PARMS}'
        ;;
    ds-modbus)
        setup_device_replacement_env_values "ds-modbus" "true"
        COMMAND="\/device-modbus "'${DEFAULT_EDGEX_RUN_CMD_PARMS}'
        ;;
    ds-mqtt)
        setup_device_replacement_env_values "ds-mqtt" "true"
        COMMAND="\/device-mqtt "'${DEFAULT_EDGEX_RUN_CMD_PARMS}'
        ;;
    ds-random)
        setup_device_replacement_env_values "ds-random" "true"
        COMMAND="\/device-random "'${DEFAULT_EDGEX_RUN_CMD_PARMS}'
        ;;
    ds-rest)
        # ds-rest has default token so we don't need to append
        setup_device_replacement_env_values "ds-rest" "false"
        COMMAND="\/device-rest-go "'${DEFAULT_EDGEX_RUN_CMD_PARMS}'
        ;;
    ds-snmp)
        setup_device_replacement_env_values "ds-snmp" "true"
        COMMAND="\/device-snmp-go "'${DEFAULT_EDGEX_RUN_CMD_PARMS}'
        ;;
    ds-virtual)
        # ds-virtual has default token so we don't need to append
        setup_device_replacement_env_values "ds-virtual" "false"
        COMMAND="\/device-virtual "'${DEFAULT_EDGEX_RUN_CMD_PARMS}'
        ;;
    taf-perf)
        echo "composite taf-perf section"
        IS_TAF="true"
        ./gen_compose.sh no-delete asc-mqtt ds-virtual ds-rest
        continue
        ;;
    taf-secty)
        echo "composite taf-secty section"
        IS_TAF="true"
        ./gen_compose.sh no-delete asc-http asc-mqtt ds-virtual ds-rest ds-modbus
        continue
        ;;
    *)
        echo "skip as $arg is not a supported service"
        continue
        ;;
    esac

    echo "generating additive compose file of service $arg for security mode"
    SERVICE_COMPOSE_PATH=./"$STAGING_DIR"/add-"$SERVICE_NAME"-secure.yml
    sed 's/${SERVICE_NAME}:/'"$SERVICE_NAME"':/g' "$ADD_SERVICE_SECURE_FILE_TEMPLATE" > "$SERVICE_COMPOSE_PATH"
    sed -i 's/${SERVICE_KEY}/'"$SERVICE_KEY"'/g' "$SERVICE_COMPOSE_PATH"
    sed -i 's/${COMMAND}/'"$COMMAND"'/g' "$SERVICE_COMPOSE_PATH"
    sed -i 's/##${ENVIRONMENT_SECTION}/'"$ENV_SECTION"'/g' "$SERVICE_COMPOSE_PATH"
    ENV_SECTION=''
    COMPOSE_FILES="$COMPOSE_FILES -f $SERVICE_COMPOSE_PATH"
done

# special treatment for "add-taf-device-services-mods.yml" when it is in COMPOSE_FILES list
# since there is override for both services ds-virtual and ds-modbus in that yml,
# we want to move that file as the last entry
#contain_taf_ds_mods
EXTRACT_PATTERN="-f add-taf-device-services-mods.yml"
COMPSE_FILE_LIST_PATTERN_PRIOR=$(echo "${COMPOSE_FILES%%$EXTRACT_PATTERN*}")
COMPSE_FILE_LIST_PATTERN_POSTERIOR=$(echo "${COMPOSE_FILES#*$EXTRACT_PATTERN}")
if [ "$COMPSE_FILE_LIST_PATTERN_PRIOR" != "$COMPSE_FILE_LIST_PATTERN_POSTERIOR" ]; then
    # in this case, there is pattern got removed and thus we want to append it to the list
    COMPOSE_FILES="$COMPSE_FILE_LIST_PATTERN_PRIOR $COMPSE_FILE_LIST_PATTERN_POSTERIOR $EXTRACT_PATTERN"
fi

# skip the final compose if IS_TAF is true as they were already done in composite way by recusrively calls
if [ ! "$IS_TAF" = "true" ]; then
    echo "list of sub compose files: $COMPOSE_FILES"
    docker-compose -p edgex $COMPOSE_FILES config > docker-compose.yml
    IS_TAF="false"
fi
