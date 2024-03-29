#!/usr/bin/env bash
set -o pipefail
set -o errexit

if [ "$1" = "-h" ]; then
   cat << EOF
Usage: deploy-seed.sh [--skip-minio] [--skip-minio-lifecycle-mgr]
Deploy MLA backend components on a KKP Seed cluster.
--skip-minio               this can be used if you want to configure MLA backend components to user existing minio in the cluster, if this flag is not specified, it will deploy a minio instance for you.
--skip-minio-lifecycle-mgr this will skip the installation of minio lifecycle manager.
--skip-dependencies        this will skip downloading dependencies for the charts from external repositories
--download-only            this will only download the dependencies without installing MLA stack
EOF
   exit 0
fi

skip_minio=false
skip_minio_lifecycle_mgr=false
skip_dependencies=false
download_only=false

for var in $@
do
    if [ "$var" = "--skip-minio" ]; then
        skip_minio=true
    fi
    if [ "$var" = "--skip-minio-lifecycle-mgr" ]; then
        skip_minio_lifecycle_mgr=true
    fi
    if [ "$var" = "--skip-dependencies" ]; then
        skip_dependencies=true
    fi
    if [ "$var" = "--download-only" ]; then
        download_only=true
    fi
done

if [ "$skip_dependencies" != true ]; then
    echo ""
    echo "fetching charts..."
    hack/fetch-chart-dependencies.sh
    echo "done."
fi

if [ "$download_only" = true ]; then
    echo ""
    echo "exiting without installing the stack due to --download-only"
    exit 0
fi

if [ "$skip_minio" != true ]; then
    echo ""
    echo "Installing Minio"
    helm --namespace mla upgrade --atomic --create-namespace --install minio charts/minio --values config/minio/values.yaml
fi

if [ "$skip_minio_lifecycle_mgr" != true ]; then
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
helm --namespace mla upgrade --atomic --create-namespace --install cortex charts/cortex --values config/cortex/values.yaml --timeout 1200s

echo ""
echo "Installing Loki"
helm --namespace mla upgrade --atomic --create-namespace --install loki-distributed charts/loki-distributed --values config/loki/values.yaml --timeout 600s

echo ""
echo "Installing Alertmanager Proxy"
helm --namespace mla upgrade --atomic --create-namespace --install alertmanager-proxy charts/alertmanager-proxy
