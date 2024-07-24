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

# This shell script is used to generate the extension of docker-compose yaml file in secure mode dynamically

num_of_args=$#
# the positional input arguments are <"service_name"> <"service_key"> <"executable"> ["parameters"]
# where the last argument is optional with default value
# we use the inherited pattern to reduce the input number of arguments from the caller
# i.e. if only provided one input argument, then the 2nd and 3rd argument will be the same as the first argument

service_name='' service_key='' executable='' params=' ${CP_FLAGS}'
case "$num_of_args" in
0)
  echo "ERROR: Invalid number of arguments, should be at least 1"
  exit 1
  ;;
1)
  service_name=$1 service_key=$1 executable=$1
  ;;
2)
  service_name=$1 service_key=$2 executable=$2
  ;;
3)
  service_name=$1 service_key=$2 executable=$3
  ;;
4 | *)
  service_name=$1 service_key=$2 executable=$3 params=$4
  ;;
esac

DEFAULT_GEN_EXT_DIR="gen_ext_compose"
GEN_EXT_DIR="${GEN_EXT_DIR:-$DEFAULT_GEN_EXT_DIR}"
mkdir -p "$GEN_EXT_DIR"

ADD_SERVICE_SECURE_FILE_TEMPLATE="add-service-secure-template.yml"

SERVICE_EXT_COMPOSE_PATH="./${GEN_EXT_DIR}/add-${service_name}-secure.yml"
sed 's/${SERVICE_NAME}:/'"$service_name"':/g' "$ADD_SERVICE_SECURE_FILE_TEMPLATE" > "$SERVICE_EXT_COMPOSE_PATH"
sed -i 's/${SERVICE_KEY}/'"$service_key"'/g' "$SERVICE_EXT_COMPOSE_PATH"
sed -i 's,${EXECUTABLE},'"$executable"',g' "$SERVICE_EXT_COMPOSE_PATH"
if [ "$ZERO_TRUST" = "1" ]; then
  sed -i 's,${ZERO_TRUST},#,g' "$SERVICE_EXT_COMPOSE_PATH"
  cat >> "$SERVICE_EXT_COMPOSE_PATH" <<HERE
    # env_file does not override environment and these values are set in the add-* templates
    # use a heredoc and append it to the generated file accordingly so that docker compose will
    # reduce it down and override as expected
    environment:
      SERVICE_HOST: ${service_name}.edgex.ziti
      SERVICE_PORT: 80
    ports: !reset null
HERE
else
  sed -i 's,${ZERO_TRUST},,g' "$SERVICE_EXT_COMPOSE_PATH"
fi
case "${service_name}" in
  device-bacnet-ip | device-bacnet-mstp | device-coap | device-gpio)
    # These services don't have dumb-init in their containers, causing an issue for the wait script, use sh instead
    sed -i 's/${SHELL_OVERRIDE}/"\/bin\/sh", /g' "$SERVICE_EXT_COMPOSE_PATH"
    ;;
  *)
    sed -i 's/${SHELL_OVERRIDE}//g' "$SERVICE_EXT_COMPOSE_PATH"
    ;;
esac
# optional with default value
if [ "$num_of_args" -eq 4 ]; then
    sed -i 's, ${CP_FLAGS},'"$params"',g' "$SERVICE_EXT_COMPOSE_PATH"
fi


if [ "$IS_MQTT_BUS" = "1" ]; then
  if [ "$service_name" = "app-service-mqtt-export" ] || [ "$service_name" = "app-scalability-test-mqtt-export" ]; then
    ENV_SECTION='environment:\r      WRITABLE_INSECURESECRETS_MQTT_SECRETS_USERNAME: USERNAME_PLACEH_OLDER\r      WRITABLE_INSECURESECRETS_MQTT_SECRETS_PASSWORD: PASSWORD_PLACE_HOLDER'
    sed -i 's/##${ENVIRONMENT_SECTION}/'"$ENV_SECTION"'/g' "$SERVICE_EXT_COMPOSE_PATH"
  fi
  if [ "$service_name" = "device-mqtt" ]; then
    ENV_SECTION='environment:\r      MQTTBROKERINFO_AUTHMODE: usernamepassword'
    sed -i 's/##${ENVIRONMENT_SECTION}/'"$ENV_SECTION"'/g' "$SERVICE_EXT_COMPOSE_PATH"
  fi
fi

# return the extension compose file path
echo "$SERVICE_EXT_COMPOSE_PATH"
