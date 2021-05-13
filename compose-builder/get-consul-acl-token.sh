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

# DEV and ARCH are set in environment prior to calling script
# example: DEV=-dev ARCH=-arm64 ./get-consul-acl-token.sh

# versions are loaded from .env file
. ./.env

if [ "$DEV" = "-dev" ]; then
  CORE_EDGEX_REPOSITORY=edgexfoundry
  CORE_EDGEX_VERSION=0.0.0
fi

docker exec -it edgex-core-consul /bin/sh -c \
  'cat "$STAGEGATE_REGISTRY_ACL_BOOTSTRAPTOKENPATH" | jq -r '.SecretID' '
