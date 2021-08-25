#!/usr/bin/env bash

KKP_REPO_DIR="${KKP_REPO_DIR:-}"
KKP_REPO_URL="${KKP_REPO_URL:-https://github.com/kubermatic/kubermatic.git}"
KKP_REPO_TAG="${KKP_REPO_TAG:-weekly-2021-33}"

TMP_REPO_DIR="${TMP_REPO_DIR:-/tmp/kubermatic-sources}"
TMP_DASHBOARD_DIR="${TMP_DASHBOARD_DIR:-/tmp/kkp-dashboards}"

if [ "${KKP_REPO_DIR}" == "" ] || [ ! -d "${KKP_REPO_DIR}" ]; then
    git clone --depth 1 --branch "${KKP_REPO_TAG}" "${KKP_REPO_URL}" ${TMP_REPO_DIR}
    KKP_REPO_DIR=${TMP_REPO_DIR}
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

if [ "${KKP_REPO_DIR}" == "${TMP_REPO_DIR}" ]; then
  rm -rf "${TMP_REPO_DIR}"
fi
rm -r ${TMP_DASHBOARD_DIR}
