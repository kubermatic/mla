# User Cluster MLA Stack for KKP
This repository contains a **work in progress** implementation of User Cluster MLA (Monitoring Logging & Alerting)
stack for KKP (Kubermatic Kubernetes Platform).

The architecture and implementation details can be found in the [KKP Proposal Document for User CLuster MLA](https://github.com/kubermatic/kubermatic/blob/master/docs/proposals/user-cluster-mla.md).

## Requirements
The User Cluster MLA Stack has to be manually installed into every Seed Cluster of a KKP installation.
In each Seed Cluster, it will need about:
 - 2 vCPUs
 - 14 GB of RAM

Apart from that, it will by default claim the following storage from the `kubermatic-fast` storage class:
- 50 Gi for minio (storage for logs & metrics)
- 10 Gi for Grafana
- 4 x 2 Gi for internal processing services (ingesters, compactor, store gateway)

## Limitations & Known Issues
As the MLA stack is still work in progress, there are some known limitations and issues:
- MLA is always enabled (and has to be installed) in every Seed Cluster of a KKP installation (fixed in [#6967](https://github.com/kubermatic/kubermatic/pull/6967) on 2020-05-04)
- MLA does not work if the Tunneling expose strategy is used (fixed in [#6936](https://github.com/kubermatic/kubermatic/pull/6936) on 2020-05-04)
- Race condition in Grafana datasource controller, which may cause Grafana data sources to appear in a wrong Organization / KKP Project (issue: [#6981](https://github.com/kubermatic/kubermatic/issues/6981))
- Grafana is exposed via a LB Service, accessible for a single admin user with password authentication (auto-generated, stored in a secret)
- Alertmanager UI is not yet exposed, as it requires the Alertmanager authorization proxy implementation to be finished

## Installation
The MLA stack has to be installed manually into every KKP Seed Cluster, which is hosting User Clusters where the
feature should be available. Once installed, it has to be explicitly enabled in the global KKP Configuration,
Seed configuration and in each User Cluster.

### Deploy Seed Cluster Components
The MLA stack can be deployed into a KKP Seed Cluster using the following helper script which installs
all necessary Helm charts:
```bash
./hack/deploy-seed.sh
```
If any customization is needed, the steps in the script can be manually reproduced with tweaked Helm values.

### Enable The MLA Feature in KKP Configuration
Since the User Cluster MLA feature is still under development, it has to be explicitly enabled via a feature gate
in the `KubermaticConfiguration`, e.g.:
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

### Enable The MLA Stack in Seed
Since the MLA stack has to be manually installed into every KKP Seed Cluster, it is necessary to explicitly enable
it on the Seed Cluster level after it is installed. This can be done via `mla.user_cluster_mla_enabled` option
of the `Seed` Custom Resource / API object, e.g.:

**NOTE:** this Seed option was added in [#6967](https://github.com/kubermatic/kubermatic/pull/6967) on 2020-05-04.
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

### Enable MLA for a User Cluster
If the MLA stack is installed and enabled in the Seed, the monitoring (metrics collection) and logging (logs collection)
can be enabled in any User Cluster via `mla.monitoringEnabled` and `mla.loggingEnabled` options of the Cluster
Custom Resource / API object, e.g.:
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

## Accessing the Logs & Metrics
At this point, the Grafana UI which provides access to the metrics and logs of individual User Clusters,
which is running in each Seed Cluster, is exposed via a LB Service in the `mla` namespace in the Seed Cluster.
To retrieve its external IP:

```bash
$ kubectl get svc grafana -n mla
NAME      TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
grafana   LoadBalancer   10.47.243.92   35.234.122.67   80:30289/TCP   4d1h
```

The Grafana is currently accessible only for a single admin user with password authentication. The auto-generated
password is stored in the `grafana` secret in the `mla` namespace:

```bash
kubectl get secret grafana -n mla
NAME      TYPE     DATA   AGE
grafana   Opaque   3      4d1h
```

Once you are logged in the Grafana UI as the admin user, you can switch between individual Organizations
(KKP Projects) via the icon in the bottom left corner of the UI.