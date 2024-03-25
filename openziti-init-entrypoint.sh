#!/usr/bin/env bash
OPENZITI_PERSISTENCE_PATH=/edgex_openziti
openziti_server_and_port="openziti:1280"
openziti_user=admin
openziti_pwd=admin
oidc_server="vault:8200"
ext_signer_name="vault.clients"
auth_policy_name="${ext_signer_name}.auth.policy"
iss="/v1/identity/oidc"
jwks="http://vault:8200/v1/identity/oidc/.well-known/keys"
aud="edgex"
claim="name"

while [[ "$(curl -w "%{http_code}" -m 1 -s -k -o /dev/null https://${openziti_server_and_port}/version)" != "200" ]]; do echo "waiting for https://${openziti_server_and_port}"; sleep 3; done; echo "controller online"
ziti edge login ${openziti_server_and_port} -u $openziti_user -p $openziti_pwd -y

ext_jwt_id=$(ziti edge create ext-jwt-signer "${ext_signer_name}" $iss -u $jwks -a $aud -c $claim)

edgex_auth_policy=$(ziti edge create auth-policy "${auth_policy_name}" \
  --primary-ext-jwt-allowed \
  --primary-ext-jwt-allowed-signers "${ext_jwt_id}")

function deleteEdgexService {
  local svc="edgex.$1"
  ziti edge delete config "${svc}-intercept"
  ziti edge delete service "${svc}"
  ziti edge delete erp "${svc}.erp"
  ziti edge delete sp "${svc}.bind"
  ziti edge delete sp "${svc}.dial"
}

function makeEdgexService {
  local svc="edgex.$1"
  local int="$1.edgex.ziti"
  ziti edge create identity "${svc}" --external-id "${1}" -a "edgex,${svc}-servers" -P "${edgex_auth_policy}"
  ziti edge create config "${svc}-intercept" intercept.v1 '{"protocols":["tcp"],"addresses":["'"${int}"'"], "portRanges":[{"low":80, "high":80}]}'
  ziti edge create service "${svc}" -a "${svc}" --configs "${svc}-intercept"
  ziti edge create edge-router-policy "${svc}.erp" --identity-roles "#${svc}" --edge-router-roles '#all'
  ziti edge create service-policy "${svc}.bind" Bind --service-roles "#${svc}" --identity-roles "#${svc}-servers"
  ziti edge create service-policy "${svc}.dial" Dial --service-roles "#${svc}" --identity-roles "#${svc}-clients"
}

sleep 1
makeEdgexService 'core-command'
makeEdgexService 'core-data'
makeEdgexService 'core-metadata'
makeEdgexService 'device-virtual'
makeEdgexService 'device-rest'
makeEdgexService 'rules-engine'
makeEdgexService 'support-notifications'
makeEdgexService 'support-scheduler'
makeEdgexService 'sys-mgmt-agent'
makeEdgexService 'ui'
makeEdgexService 'app-rules-engine'


ziti edge create identity edgexuser -P "${edgex_auth_policy}" --external-id edgexuser -a edgex.device-virtual-servers,edgex.core-command-clients,edgex.core-data-clients,edgex.core-metadata-clients,edgex.device-virtual-clients,edgex.rules-engine-clients,edgex.support-notifications-clients,edgex.support-scheduler-clients,edgex.sys-mgmt-agent-clients
ziti edge update identity edgex.rules-engine -a edgex.rules-engine-servers,edgex.core-command-clients
ziti edge update identity edgex.device-virtual -a edgex.device-virtual-servers,edgex.core-command-clients,edgex.core-data-clients,edgex.core-metadata-clients,edgex.device-virtual-clients,edgex.rules-engine-clients,edgex.support-notifications-clients,edgex.support-scheduler-clients,edgex.sys-mgmt-agent-clients
ziti edge update identity edgex.ui -a edgex.device-virtual-servers,edgex.core-command-clients,edgex.core-data-clients,edgex.core-metadata-clients,edgex.device-virtual-clients,edgex.rules-engine-clients,edgex.support-notifications-clients,edgex.support-scheduler-clients,edgex.sys-mgmt-agent-clients
ziti edge update identity edgex.device-rest -a edgex.device-rest-servers,edgex.core-command-clients,edgex.core-data-clients,edgex.core-metadata-clients,edgex.device-virtual-clients,edgex.rules-engine-clients,edgex.support-notifications-clients,edgex.support-scheduler-clients,edgex.sys-mgmt-agent-clients
ziti edge update identity edgex.core-command -a edgex,edgex.core-command-servers,edgex.core-metadata-clients,edgex.device-virtual-clients

echo "granting additional dial capabilities to app-rules-engine"
ziti edge update identity edgex.app-rules-engine -a edgex,edgex.app-rules-engine-servers,edgex.core-metadata-clients

echo " "
echo "ext-jwt-id     : ${ext_jwt_id}"
echo "auth policy id : ${edgex_auth_policy}"
echo " "

echo "creating the healthcheck proxy identity"
ziti edge create identity \
  healthcheck -o ${OPENZITI_PERSISTENCE_PATH}/healthcheck.jwt \
  -a 'edgex.app-rules-engine-clients,edgex.device-rest-clients,edgex.core-command-clients,'\
'edgex.core-data-clients,edgex.core-metadata-clients,edgex.device-virtual-clients,'\
'edgex.rules-engine-clients,edgex.support-notifications-clients,edgex.support-scheduler-clients,'\
'edgex.sys-mgmt-agent-clients'

ziti edge enroll ${OPENZITI_PERSISTENCE_PATH}/healthcheck.jwt