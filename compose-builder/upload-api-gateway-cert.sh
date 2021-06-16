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


# usage function for uploading tls cert:
usage()
{
  echo "Usage: uplaod-api-gateway-cert.sh CERT_INPUT_FILE=<full-path-for-cert-input-file> KEY_INPUT_FILE=<full-path-for-key-input-file> [EXTRA-SNIS=<comma-separated-list-for-server-name>]"
  echo "\tBoth CERT_INPUT_FILE and KEY_INPUT_FILE are required."
  echo "\tEXTRA_SNIS is optional"
  exit 1
}

# DEV and ARCH are set in environment prior to calling script
# example: DEV=-dev ARCH=-arm64 ./upload-api-gateway-cert.sh

# versions are loaded from .env file
. ./.env

if [ "$DEV" = "-dev" ]; then
  CORE_EDGEX_REPOSITORY=edgexfoundry
  CORE_EDGEX_VERSION=0.0.0
fi

# required input sanity checks
if [ "$CERT_INPUT_FILE" = "" ]; then
  echo "Missing env parameter: CERT_INPUT_FILE"
  usage
fi
if [ "$KEY_INPUT_FILE" = "" ]; then
  echo "Missing  env parameter: KEY_INPUT_FILE"
  usage
fi

# staging the input files into temporary files
STAGING="staging-cert"
rm -rf ${STAGING}
mkdir -p ${STAGING}

cp ${CERT_INPUT_FILE} ${STAGING}
cp ${KEY_INPUT_FILE} ${STAGING}

CERT_FILE_NAME=$(basename ${CERT_INPUT_FILE})
KEY_FILE_NAME=$(basename ${KEY_INPUT_FILE})

echo "Uploading Kong TLS certificate with certificate file: ${CERT_FILE_NAME}, key file: ${KEY_FILE_NAME}, extra server name list: [${EXTRA_SNIS}]"
docker run --rm -it -e KONGURL_SERVER=edgex-kong --network edgex_edgex-network --entrypoint "" -v ${PWD}/${STAGING}:/${STAGING} \
       ${CORE_EDGEX_REPOSITORY}/security-proxy-setup${ARCH}:${CORE_EDGEX_VERSION}${DEV} \
        /edgex/secrets-config proxy tls --incert /${STAGING}/${CERT_FILE_NAME} \
        --inkey /${STAGING}/${KEY_FILE_NAME} \
        --snis "${EXTRA_SNIS}"

if [ $? = 0 ]; then
  echo "Kong TLS certificate uploaded"
else
  echo "Failed to upload Kong TLS certificate"
fi

rm -rf ${STAGING}
