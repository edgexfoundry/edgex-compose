#!/bin/sh
# /*******************************************************************************
#  * Copyright 2022 Intel Corporation.
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

# This shell script is used to generate the NATS MessageBus extension of docker-compose yaml file
# for App Service or Device service dynamically

num_of_args=$#
# the positional input arguments are <"service_name"> <-a/-d>
# where the -a indicates App Service and -d indicates Device Service

service_name='' service_type='' ADD_SERVICE_SECURE_FILE_TEMPLATE=''

if [ "$num_of_args" -ne 2 ]; then
  echo "ERROR: Invalid number of arguments, should be at 2: <service-name> <-a or -d>"
  exit 1
fi

service_name=$1
service_type=$2

DEFAULT_GEN_EXT_DIR="gen_ext_compose"
GEN_EXT_DIR="${GEN_EXT_DIR:-$DEFAULT_GEN_EXT_DIR}"
mkdir -p "$GEN_EXT_DIR"

if [ "$service_type" = "-a" ]; then
  ADD_NATS_MESSAGEBUS_TEMPLATE="add-nats-messagebus-app-template.yml"
else
  if  [ "$service_type" = "-d" ]; then
     ADD_NATS_MESSAGEBUS_TEMPLATE="add-nats-messagebus-device-template.yml"
  else
      echo "ERROR: Invalid 2nd argument '$service_type'. Must be -a (App Service) or -d (device service)"
      exit 1
  fi
fi

SERVICE_EXT_COMPOSE_PATH=./"$GEN_EXT_DIR"/add-"$service_name"-nats-messagebus.yml
sed 's/${SERVICE_NAME}:/'"$service_name"':/g' "$ADD_NATS_MESSAGEBUS_TEMPLATE" > "$SERVICE_EXT_COMPOSE_PATH"

# return the extension compose file path
echo "$SERVICE_EXT_COMPOSE_PATH"
