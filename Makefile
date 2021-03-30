# /*******************************************************************************
#  * Copyright 2020 Intel
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
#  *
#  *******************************************************************************/

.PHONY: help portainer portainer-down pull run pull-ui run-ui down-ui down clean get-token
.SILENT: help get-token

help:
	echo "See README.md in this folder"

ARGS:=$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

OPTIONS:=" arm64 no-secty " # Must have spaces around words for `filter-out` function to work properly

ifeq (arm64, $(filter arm64,$(ARGS)))
	ARM64=-arm64
	ARM64_OPTION=arm64
endif
ifeq (no-secty, $(filter no-secty,$(ARGS)))
	NO_SECURITY:=-no-secty
endif

SERVICES:=$(filter-out $(OPTIONS),$(ARGS))

portainer:
	docker-compose -p portainer -f docker-compose-portainer.yml up -d

portainer-down:
	docker-compose -p portainer -f docker-compose-portainer.yml down

pull:
	docker-compose -f docker-compose-hanoi${NO_SECURITY}${ARM64}.yml pull ${SERVICES}

run:
	docker-compose -p edgex -f docker-compose-hanoi${NO_SECURITY}${ARM64}.yml up -d ${SERVICES}

pull-ui:
	docker-compose -p edgex -f docker-compose-hanoi-ui${ARM64}.yml pull

run-ui:
	docker-compose -p edgex -f docker-compose-hanoi-ui${ARM64}.yml up -d

down-ui:
	docker-compose -p edgex -f docker-compose-hanoi-ui${ARM64}.yml down

down: down-ui
	# Make sure UI is down first and then use secure version since it is a super set and
	# can down all service even if not include in what was brought up.
	docker-compose -p edgex -f docker-compose-hanoi.yml down

clean: down
	-docker rm $$(docker ps --filter "network=edgex_edgex-network" --filter "network=edgex_default" -aq) 2> /dev/null
	docker volume prune -f && \
	docker network prune -f

get-token:
	docker run --rm \
		-e SECRETSERVICE_SERVER=edgex-vault \
		-e KONGURL_SERVER=kong \
		-e SECRETSERVICE_TOKENPATH=/tmp/edgex/secrets/edgex-security-proxy-setup/secrets-token.json \
		-e SECRETSERVICE_CACERTPATH=/tmp/edgex/secrets/ca/ca.pem \
		--network edgex_edgex-network \
		--volume /tmp/edgex/secrets/ca:/tmp/edgex/secrets/ca:ro,z \
		--volume /tmp/edgex/secrets/edgex-security-proxy-setup:/tmp/edgex/secrets/edgex-security-proxy-setup:ro,z \
		edgexfoundry/docker-security-proxy-setup-go$(ARM64):1.3.0 \
		--init=false --useradd=developer --group=admin \
		| grep " access token for user developer" | sed 's/.*: \([^.]*\.[^.]*\.[^.]*\).*/\1/'
