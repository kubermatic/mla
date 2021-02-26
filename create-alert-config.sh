#!/usr/bin/env bash

GW_ADDRESS=mla-gateway-ext.cluster-xyz.svc.cluster.local/api/v1/alerts

if [ -n "$1" ]; then
  GW_ADDRESS=$1
fi

echo "Using Gateway: ${GW_ADDRESS}"

# default tenant name
TENANT_NAME=xyz

if [ -n "$2" ]; then
  TENANT_NAME=$2
fi

curl -XPOST http://${GW_ADDRESS}/api/v1/alerts -d "
alertmanager_config: |
  global:
    smtp_smarthost: 'localhost:25'
    smtp_from: '${TENANT_NAME}@example.org'
  route:
    receiver: ${TENANT_NAME}
  receivers:
    - name: ${TENANT_NAME}
      email_configs:
      - to: '${TENANT_NAME}@example.org'"
