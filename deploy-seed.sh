#!/usr/bin/env bash

# MLA components namespace
MLA_NS=mla

echo "Adding Helm repos"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add cortex-helm https://cortexproject.github.io/cortex-helm-chart
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add minio https://helm.min.io

helm repo update

echo ""
echo "Installing Minio"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install minio minio/minio --version 8.0.10 --values config/minio/values.yaml

echo ""
echo "Installing Cassandra"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install cassandra bitnami/cassandra --version 7.3.2 --values config/cassandra/values.yaml

echo ""
echo "Installing Grafana"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install grafana grafana/grafana --version 6.4.2 --values config/grafana/values.yaml

echo ""
echo "Installing Cortex"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install cortex cortex-helm/cortex --version 0.3.0 --values config/cortex/values.yaml

echo ""
echo "Installing Loki"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install loki-distributed charts/loki-distributed --values config/loki/values.yaml
