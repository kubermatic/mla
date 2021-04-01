#!/usr/bin/env bash

# MLA components namespace
MLA_NS=mla

# default domain
DOMAIN=alerts.dev.kubermatic.io

if [ -n "$1" ]; then
  DOMAIN=$1
fi

echo ""
echo "Exposing Alertmanager at domain ${DOMAIN}"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install mla-am-proxy charts/alertmanager-proxy \
    --set mla.namespace=${MLA_NS} \
    --set amProxy.domain=${DOMAIN}

echo ""
echo "Make sure to setup DNS for the domain ${DOMAIN} to point to the mla-aletrmanager LoadBalancer service"
