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
- KKP Admin users can not access all Grafana organizations (KKP Projects) in Grafana UI (issue [#7045](https://github.com/kubermatic/kubermatic/issues/7045)).
- Data retention and cleanup is not yet implemented - all MLA data will be left in the Minio object store forever (issue [#7021](https://github.com/kubermatic/kubermatic/issues/7021)).
- Some MLA resources will be left running and not cleaned up after MLA is disabled on the Seed level (issue [7019](https://github.com/kubermatic/kubermatic/issues/7019)).

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

### Expose Grafana & Alertmanager UI
At this point, the Grafana & Alertmanager UI are exposed only via a ClusterIP service. To expose it to users outside of the cluster
with proper authentication in place, we will use the [IAP Helm Chart](https://github.com/kubermatic/kubermatic/tree/master/charts/iap)
from the Kubermatic repository.

Let's start with preparing the values.yaml for the IAP Helm Chart. A starting point can be found in the
[config/iap/values.example.yaml](config/iap/values.example.yaml) file of the MLA repository:
 - modify the base domain under which your KKP installation is available (`kkp.example.com` in `iap.oidc_issuer_url`
   and `iap.deployments.grafana.ingress.host`),
 - set `iap.deployments.grafana.client_secret` + `iap.deployments.grafana.encryption_key` and
   `iap.deployments.alertmanager.client_secret` + `iap.deployments.alertmanager.encryption_key` to newly generated keys
   (they can be generated e.g. with `cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32`),
 - configure how the users should be authenticated in `iap.deployments.grafana.config` and
   `iap.deployments.alertmanager.config` (e.g. modify `YOUR_GITHUB_ORG` and `YOUR_GITHUB_TEAM` placeholders)
    - see the [OAuth Provider Configuration](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider)
   for more details.

It is also necessary to set up your infrastructure accordingly:
 - configure your DNS with the DNS entry for the domain name that you used in `iap.deployments.grafana.ingress.host`
   and `iap.deployments.alertmanager.ingress.host` so that it points to the ingress-controller service of KKP,
 - configure the Dex in KKP with the proper configuration for Grafana and Alertmanager IAP, e.g. using the following
   snippet that can be placed into the KKP `values.yaml`. Make sure to modify the `RedirectURIs` with your domain name used in
   `iap.deployments.grafana.ingress.host` and `iap.deployments.alertmanager.ingress.host` and secret with your
   `iap.deployments.grafana.client_secret` and `iap.deployments.alertmanager.client_secret`:

```yaml
dex:
  clients:
  - RedirectURIs:
    - https://grafana.mla.kkp.example.com/oauth/callback
    id: mla-grafana
    name: mla-grafana
    secret: YOUR_CLIENT_SECRET
  - RedirectURIs:
    - https://alertmanager.mla.kkp.example.com/oauth/callback
    id: mla-alertmanager
    name: mla-alertmanager
    secret: YOUR_CLIENT_SECRET
```

At this point, we can install the IAP Helm chart into the `mla` namespace, e.g. as follows:
```sh
git clone --depth 1 https://github.com/kubermatic/kubermatic.git
helm --namespace mla upgrade --atomic --create-namespace --install iap kubermatic/charts/iap --values config/iap/values.yaml
```

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
The Grafana UI is avaialable via the ingress configured in the "Expose Grafana" installation step. Once you are
logged in the Grafana UI, you can switch between individual Organizations (KKP Projects) that you have access to
using the user avatar icon in the bottom left corner of the UI: "Current Org:" > "Switch".