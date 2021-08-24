#!/usr/bin/env bash

KKP_REPO_DIR="${KKP_REPO_DIR:-${HOME}/go/src/k8c.io/kubermatic}"
TMP_DASHBOARD_DIR="${TMP_DASHBOARD_DIR:-/tmp/kkp-dashboards}"

if [ ! -d "${KKP_REPO_DIR}" ]
then
    echo "Directory ${KKP_REPO_DIR} DOES NOT exist."
    echo "Please set the KKP_REPO_DIR env var to point to the KKP repo directory."
    exit 1
fi

mkdir ${TMP_DASHBOARD_DIR}
cp -r ${KKP_REPO_DIR}/charts/monitoring/grafana/dashboards/kubernetes ${TMP_DASHBOARD_DIR}

rm ${TMP_DASHBOARD_DIR}/kubernetes/etcd*                 # do not expose etcd metrics
rm ${TMP_DASHBOARD_DIR}/kubernetes/objects.json          # etcd objects
rm ${TMP_DASHBOARD_DIR}/kubernetes/kubelets*             # requires recording rules
rm ${TMP_DASHBOARD_DIR}/kubernetes/node-namespaces.json  # requires recording rules
rm ${TMP_DASHBOARD_DIR}/kubernetes/node-resources.json   # requires recording rules
rm ${TMP_DASHBOARD_DIR}/kubernetes/resources*            # requires recording rules
rm ${TMP_DASHBOARD_DIR}/kubernetes/volumes.json          # requires recording rules

kubectl create configmap grafana-dashboards-kkp-kubernetes -n mla --from-file=${TMP_DASHBOARD_DIR}/kubernetes -o yaml --dry-run=client > dashboards/kkp-kubernetes.yaml

sed -i 's/job=\\"cadvisor\\"/job=\\"kubernetes-nodes-cadvisor\\"/g' dashboards/kkp-kubernetes.yaml
sed -i 's/app=\\"node-exporter\\"/job=\\"node-exporter\\"/g' dashboards/kkp-kubernetes.yaml

rm -r ${TMP_DASHBOARD_DIR}
