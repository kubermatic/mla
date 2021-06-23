#!/usr/bin/env bash

source ./hack/lib.sh

echodate ""
echodate "Installing Minio"
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install minio charts/minio --values config/minio/values.yaml

echodate ""
echodate "Installing Grafana"
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install grafana charts/grafana --values config/grafana/values.yaml

echodate ""
echodate "Installing Cortex"
helm3 dependency update charts/cortex  # need that to store memcached in charts directory
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install cortex charts/cortex --values config/cortex/values.yaml

echodate ""
echodate "Installing Loki"
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install loki-distributed charts/loki-distributed --values config/loki/values.yaml

echodate ""
echodate "Installing Alertmanager Proxy"
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install alertmanager-proxy charts/alertmanager-proxy

echodate ""
echodate "Installing Minio Bucket Lifecycle Manager"
helm3 --namespace ${MLA_NS} upgrade --atomic --create-namespace --install minio-lifecycle-mgr charts/minio-lifecycle-mgr --values config/minio-lifecycle-mgr/values.yaml
