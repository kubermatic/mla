#!/usr/bin/env bash

# MLA components namespace
MLA_NS=mla

echo "Adding Helm repos"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo ""
echo "Installing Cassandra"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install cassandra bitnami/cassandra --values config/cassandra/values.yaml

echo ""
echo "Installing Loki"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install loki-distributed charts/loki-distributed --values config/loki/values.yaml

echo ""
echo "Installing Grafana"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install grafana grafana/grafana --values config/grafana/values.yaml

echo ""
echo "Installing a Gateway for cluster-xyz"
helm --namespace cluster-xyz upgrade --atomic --create-namespace --install mla-gw charts/gateway --set mla.namespace=${MLA_NS} --set mla.tenantID=user1

echo ""
echo "Installing a PromLabelProxy"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install prom-label-proxy charts/prom-label-proxy

echo ""
echo "Installing a Thanos"
helm --namespace ${MLA_NS} upgrade --atomic --create-namespace --install thanos bitnami/thanos --values config/thanos/values.yaml
