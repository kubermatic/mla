#!/usr/bin/env bash

# MLA components namespace
MLA_NS=mla

# default tenant name
TENANT_NAME=xyz

if [ -n "$1" ]; then
  TENANT_NAME=$1
fi

echo ""
echo "Installing a Gateway for tenant ${TENANT_NAME}"
helm --namespace cluster-${TENANT_NAME} upgrade --atomic --create-namespace --install mla-gw-${TENANT_NAME} charts/gateway \
    --set mla.namespace=${MLA_NS} \
    --set mla.tenantID=${TENANT_NAME}
