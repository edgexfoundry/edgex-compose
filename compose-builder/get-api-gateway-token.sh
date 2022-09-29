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

# DEV and ARCH are set in environment prior to calling script
# example: DEV=-dev ARCH=-arm64 ./get-api-gateway-token.sh

# versions are loaded from .env file
. ./.env

if [ "$DEV" = "-dev" ]; then
  export CORE_EDGEX_REPOSITORY=edgexfoundry
  export CORE_EDGEX_VERSION=0.0.0-dev
fi

# Init key dir
GW_KEY_DIR=${GW_KEY_DIR:-/tmp/edgex-gateway-keys}

rm -rf ${GW_KEY_DIR}
mkdir -p ${GW_KEY_DIR}

# Build Gateway Key
openssl ecparam -name prime256v1 -genkey -noout -out ${GW_KEY_DIR}/gateway.key 2> /dev/null
openssl ec -in ${GW_KEY_DIR}/gateway.key -pubout -out ${GW_KEY_DIR}/gateway.pub 2> /dev/null

# JWT File
JWT_FILE=/tmp/edgex/secrets/security-proxy-setup/kong-admin-jwt
JWT_VOLUME=/tmp/edgex/secrets/security-proxy-setup

ID=`uuidgen`

docker run --rm -it -e KONGURL_SERVER=edgex-kong -e "ID=${ID}" -e "JWT_FILE=${JWT_FILE}" --network edgex_edgex-network --entrypoint "" -v ${GW_KEY_DIR}:/keys -v ${JWT_VOLUME}:${JWT_VOLUME} \
       ${CORE_EDGEX_REPOSITORY}/security-proxy-setup${ARCH}:${CORE_EDGEX_VERSION} \
        /bin/sh -c 'JWT=`cat ${JWT_FILE}`; /edgex/secrets-config proxy adduser --token-type jwt --id ${ID} --algorithm ES256  --public_key /keys/gateway.pub \
              --user gateway --group gateway --jwt ${JWT} > /dev/null'

docker run --rm -it -e KONGURL_SERVER=edgex-kong -e "ID=${ID}" --network edgex_edgex-network --entrypoint "" -v ${GW_KEY_DIR}:/keys \
       ${CORE_EDGEX_REPOSITORY}/security-proxy-setup${ARCH}:${CORE_EDGEX_VERSION} \
       /bin/sh -c '/edgex/secrets-config proxy jwt --algorithm ES256 --id ${ID} --private_key /keys/gateway.key'

# Clean Up
rm -rf ${GW_KEY_DIR}
