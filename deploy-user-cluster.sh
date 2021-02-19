#!/usr/bin/env bash

GW_ADDRESS=mla-gateway-ext.cluster-xyz.svc.cluster.local

if [ -n "$1" ]; then
  GW_ADDRESS=$1
fi

echo "Using Gateway: ${GW_ADDRESS}"

echo "Adding Helm repos"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo update

echo ""
echo "Installing Promtail"
helm --namespace monitoring upgrade --atomic --create-namespace --install promtail grafana/promtail --version 3.1.0 \
    --set config.lokiAddress=http://${GW_ADDRESS}/loki/api/v1/push

echo ""
echo "Installing Prometheus"
helm --namespace monitoring upgrade --atomic --create-namespace --install prometheus prometheus-community/prometheus --version 13.3.2 \
    --set alertmanager.enabled=false \
    --set server.remoteWrite[0].url=http://${GW_ADDRESS}/api/v1/receive
