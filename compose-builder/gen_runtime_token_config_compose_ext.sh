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

# This shell script is used to generate the extension of docker-compose yaml file in secure mode dynamically
# for adding configuration of runtime token provider

num_of_args=$#
# the positional input arguments are <"service_name">

service_name=''
if [ "$num_of_args" -ne 1 ]; then
  echo "ERROR: Invalid number of arguments, should be at 1: <service-name> required"
  exit 1
fi

service_name=$1

DEFAULT_GEN_EXT_DIR="gen_ext_compose"
GEN_EXT_DIR="${GEN_EXT_DIR:-$DEFAULT_GEN_EXT_DIR}"
mkdir -p "$GEN_EXT_DIR"

ADD_RUNTIME_TOKEN_CONFIG_FILE_TEMPLATE="add-runtime-token-config-template.yml"

SERVICE_EXT_COMPOSE_PATH=./"$GEN_EXT_DIR"/add-"$service_name"-runtime-token-config.yml
sed 's/${SERVICE_NAME}:/'"$service_name"':/g' "$ADD_RUNTIME_TOKEN_CONFIG_FILE_TEMPLATE" > "$SERVICE_EXT_COMPOSE_PATH"

# return the extension compose file path
echo "$SERVICE_EXT_COMPOSE_PATH"
