#!/bin/sh
# /*******************************************************************************
#  * Copyright 2022-2023 Intel Corporation.
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

username=edgexuser

# Start afresh by deleting old user
docker exec -ti edgex-security-proxy-setup ./secrets-config proxy deluser --user "${username}" --useRootToken > /dev/null

# Create new user, log in, and exchange for JWT
password=$(docker exec -ti edgex-security-proxy-setup ./secrets-config proxy adduser --user "${username}" --useRootToken | jq -r '.password')
vault_token=$(curl -ks "http://localhost:8200/v1/auth/userpass/login/${username}" -d "{\"password\":\"${password}\"}" | jq -r '.auth.client_token')
id_token=$(curl -ks -H "Authorization: Bearer ${vault_token}" "http://localhost:8200/v1/identity/oidc/token/${username}" | jq -r '.data.token')

# Check that we got sane output from the previous commands before coughing up the token
introspect_result=$(curl -ks -H "Authorization: Bearer ${vault_token}" "http://localhost:8200/v1/identity/oidc/introspect" -d "{\"token\":\"${id_token}\"}" | jq -r '.active')
if [ "${introspect_result}" = "true" ]; then
	echo "${id_token}"
	exit 0
else
	echo "ERROR" >&2
	exit 1
fi
