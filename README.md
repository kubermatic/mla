# MLA
**Work in progress** implementation of User Cluster MLA (Monitoring Logging & Alerting) for KKP.

## Requirements
The User Cluster MLA Stack has to be installed into each Seed Cluster of KKP. In each Seed Cluster, it will need
about:
 - 2 vCPUs
 - 14 GB of RAM

Apart from that, it will by default claim the following storage from the `kubermatic-fast` storage class:
- 50 Gi for minio (storage for logs & metrics)
- 10 Gi for Grafana
- 4 x 2 Gi for internal processing services (ingesters, compactor, store gateway)

## Limitations & Known Issues
TODO: enabled in all seeds
TODO: expose strategy
TODO: datasources in Grafana
TODO: Grafana exposed via a LB Service, secret auth
TODO: alertmanager

## Installation
The MLA stack has to be installed manually into each KKP Seed Cluster. Apart from that, it has to be
explicitly enabled in the global KKP Configuration, Seed configuration and in each User Cluster.

### Deploy Seed Cluster Components
The MLA stack can be deployed into a KKP Seed Cluster using the following helper script:
```bash
./hack/deploy-seed.sh
```

## Enable The MLA feature in KKP Configuration
TODO: feature gate
```yaml
apiVersion: operator.kubermatic.io/v1alpha1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  featureGates:
    UserClusterMLA:
      enabled: true
```

## Enable The MLA Stack in Seed
TODO: seed config
```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Seed
metadata:
  name: europe-west3-c
  namespace: kubermatic
spec:
  mla:
    user_cluster_mla_enabled: true
```

## Enable MLA for a User Cluster
TODO: cluster API
```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Cluster
metadata:
  name: <cluster-name>
spec:
  mla:
    monitoringEnabled: true
    loggingEnabled: true
```
