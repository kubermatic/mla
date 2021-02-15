#!/usr/bin/env bash

GW_ADDRESS=mla-gateway-ext.cluster-xyz.svc.cluster.local

if [ -n "$1" ]; then
  GW_ADDRESS=$1
fi

echo "Using Gateway: ${GW_ADDRESS}"

echo ""
echo "Adding Helm repos"
helm repo add grafana https://grafana.github.io/helm-charts

echo ""
echo "Installing Promtail"
helm --namespace promtail upgrade --atomic --create-namespace --install promtail grafana/promtail --set config.lokiAddress=http://${GW_ADDRESS}/loki/api/v1/push
