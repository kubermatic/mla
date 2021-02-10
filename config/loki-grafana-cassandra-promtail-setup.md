# Loki setup
This guide is about installing Loki, Promtail, and Grafana in a single Kubernetes cluster by using 
[Grafana official helm charts](https://github.com/grafana/helm-charts).

## Prerequisite
Before you start, make sure to add the chart repo to Helm:
```bash
helm repo add grafana https://grafana.github.io/helm-charts
```

### Install Cassandra Database in Kubernetes cluster
Make sure to add the bitnami chart repo to Helm:
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```
Then install cassandra in the cluster:
```bash
helm --namespace cassandra upgrade --atomic --create-namespace --install cassandra bitnami/cassandra --values cassandra/values.yaml
```


## Install Grafana in a cluster
```bash
helm --namespace grafana upgrade --atomic --create-namespace --install grafana grafana/grafana --values grafana/values.yaml
```

## Install Loki
```bash
helm --namespace loki upgrade --atomic --create-namespace --install loki grafana/loki-distributed --values loki/values.yaml
```

## Install Promtail
```bash
helm --namespace promtail upgrade --atomic --create-namespace --install promail grafana/promtail --values promtail/values.yaml
```

## Add Loki to Grafana
After all pods are ready, you can add Loki as a datasource in Grafana.
Go to your Grafana page, login with username `admin`, password `admin`. Then add Loki as a datasource.
The URL is the `http://loki-loki-distributed-gateway.loki.svc.cluster.local`, then enable `basic auth` in `Auth` section, put
`loki` as username, and `password` as password, and then click `Save & Test`.

Now you should see logs in your loki datasource.