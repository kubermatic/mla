#!/usr/bin/env bash

# MLA components namespace
MLA_NS=mla

echo ""
echo "Installing MLA Secrets"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install mla-secrets charts/mla-secrets --values config/mla-secrets/values.yaml

echo ""
echo "Installing Minio"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install minio charts/minio --values config/minio/values.yaml

echo ""
echo "Installing Grafana"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install grafana charts/grafana --values config/grafana/values.yaml

echo ""
echo "Installing Cortex"
helm dependency update charts/cortex  # need that to store memcached in charts directory
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install cortex charts/cortex --values config/cortex/values.yaml --timeout 1200s

echo ""
echo "Installing Loki"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install loki-distributed charts/loki-distributed --values config/loki/values.yaml --timeout 600s

echo ""
echo "Installing Alertmanager Proxy"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install alertmanager-proxy charts/alertmanager-proxy

echo ""
echo "Installing Minio Bucket Lifecycle Manager"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install minio-lifecycle-mgr charts/minio-lifecycle-mgr --values config/minio-lifecycle-mgr/values.yaml
