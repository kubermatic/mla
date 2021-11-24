#!/usr/bin/env bash

if [ "$1" = "-h" ]; then
   cat << EOF
Usage: deploy-seed.sh [-skip-minio]

Deploy MLA backend components on a KKP Seed cluster.
-skip-minio flag can be used if you want to configure MLA backend components to user existing minio in the cluster, if this flag is not specified, it will deploy a minio instance for you.
EOF
   exit 0
fi

if [ "$1" != "-skip-minio" ]; then
    echo ""
    echo "Installing Minio"
    helm --namespace mla upgrade --atomic --create-namespace --install minio charts/minio --values config/minio/values.yaml

    echo ""
    echo "Installing Minio Bucket Lifecycle Manager"
    helm --namespace mla upgrade --atomic --create-namespace --install minio-lifecycle-mgr charts/minio-lifecycle-mgr --values config/minio-lifecycle-mgr/values.yaml
fi

echo ""
echo "Installing Grafana"
helm --namespace mla upgrade --atomic --create-namespace --install grafana charts/grafana --values config/grafana/values.yaml

echo ""
echo "Installing Grafana Dashboards"
kubectl apply -f dashboards/

echo ""
echo "Installing Consul for Cortex"
helm --namespace mla upgrade --atomic --create-namespace --install consul charts/consul --values config/consul/values.yaml

echo ""
echo "Installing Cortex"
kubectl create -n mla configmap cortex-runtime-config --from-file=config/cortex/runtime-config.yaml || true
helm dependency update charts/cortex  # need that to store memcached in charts directory
helm --namespace mla upgrade --atomic --create-namespace --install cortex charts/cortex --values config/cortex/values.yaml --timeout 1200s

echo ""
echo "Installing Loki"
helm --namespace mla upgrade --atomic --create-namespace --install loki-distributed charts/loki-distributed --values config/loki/values.yaml --timeout 600s

echo ""
echo "Installing Alertmanager Proxy"
helm --namespace mla upgrade --atomic --create-namespace --install alertmanager-proxy charts/alertmanager-proxy
