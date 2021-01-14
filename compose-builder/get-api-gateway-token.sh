#!/bin/sh

# DEV and ARCH are set in environment prior to calling script
# example: DEV=-dev ARCH=-arm64 ./get-api-gateway-token.sh

# versions are loaded from .env file
. ./.env

if [ "$DEV" = "-dev" ]; then
  CORE_EDGEX_REPOSITORY=edgexfoundry
  CORE_EDGEX_VERSION=0.0.0
fi

rm -rf keys
mkdir keys
openssl ecparam -name prime256v1 -genkey -noout -out keys/ec256.key 2> /dev/null
cat keys/ec256.key | openssl ec -out keys/ec256.pub 2> /dev/null

ID=`uuidgen`
docker run --rm -it -e KONGURL_SERVER=kong --network edgex_edgex-network --entrypoint "" -v ${PWD}/keys:/keys \
       ${CORE_EDGEX_REPOSITORY}/docker-security-proxy-setup-go${ARCH}:${CORE_EDGEX_VERSION}${DEV} \
        /edgex/secrets-config proxy adduser --token-type jwt --id ${ID} --algorithm ES256  --public_key /keys/ec256.pub --user testinguser > /dev/null
docker run --rm -it -e KONGURL_SERVER=kong --network edgex_edgex-network --entrypoint "" -v ${PWD}/keys:/keys \
       ${CORE_EDGEX_REPOSITORY}/docker-security-proxy-setup-go${ARCH}:${CORE_EDGEX_VERSION}${DEV} \
       /edgex/secrets-config proxy jwt --algorithm ES256 --id ${ID} --private_key /keys/ec256.key
rm -rf keys
