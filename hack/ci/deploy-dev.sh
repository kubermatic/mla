#!/usr/bin/env bash

# Copyright 2020 The Kubermatic Kubernetes Platform contributors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

### This script is used as a postsubmit job and updates the mla stack in dev master
### cluster after every commit to master.

set -euo pipefail

cd $(dirname $0)/../..
source ./hack/lib.sh

echodate "Getting secrets from Vault"
export VAULT_ADDR=https://vault.loodse.com/
retry 5 vault write \
  --format=json auth/approle/login \
  role_id=${VAULT_ROLE_ID} secret_id=${VAULT_SECRET_ID} > /tmp/vault-token-response.json
export VAULT_TOKEN="$(cat /tmp/vault-token-response.json | jq .auth.client_token -r)"
export KUBECONFIG=/tmp/kubeconfig

# deploy to dev
vault kv get -field=kubeconfig dev/seed-clusters/dev.kubermatic.io > ${KUBECONFIG}
echodate "Successfully got secrets for dev from Vault"

## We have to use helm3 since `--create-namespace` is not available in helm2
echodate ""
echodate "Installing Minio"
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install minio charts/minio --values config/minio/values.yaml

echodate ""
echodate "Installing Grafana"
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install grafana charts/grafana --values config/grafana/values.yaml

echo ""
echo "Installing Grafana Dashboards"
kubectl apply -f dashboards/

echodate ""
echodate "Installing Cortex"
kubectl create -n mla configmap cortex-runtime-config --from-file=config/cortex/runtime-config.yaml || true
helm3 dependency update charts/cortex  # need that to store memcached in charts directory
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install cortex charts/cortex --values config/cortex/values.yaml --timeout 1200s

echodate ""
echodate "Installing Loki"
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install loki-distributed charts/loki-distributed --values config/loki/values.yaml --timeout 600s

echodate ""
echodate "Installing Alertmanager Proxy"
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install alertmanager-proxy charts/alertmanager-proxy

echodate ""
echodate "Installing Minio Bucket Lifecycle Manager"
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install minio-lifecycle-mgr charts/minio-lifecycle-mgr --values config/minio-lifecycle-mgr/values.yaml
