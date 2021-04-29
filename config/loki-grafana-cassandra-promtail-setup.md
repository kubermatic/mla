# Loki setup
This guide is about installing Loki, Promtail, and Grafana in a single Kubernetes cluster by using 
[Grafana official helm charts](https://github.com/grafana/helm-charts).

## Prerequisite
Before you start, make sure to add the chart repo to Helm:
```bash
helm repo add grafana https://grafana.github.io/helm-charts
```


## Install Grafana in a cluster
```bash
helm --namespace mla upgrade --atomic --create-namespace --install grafana grafana/grafana --values grafana/values.yaml
```

## Install Loki
```bash
helm --namespace mla upgrade --atomic --create-namespace --install loki-distributed grafana/loki-distributed --values loki/values.yaml
```

## Install Promtail
```bash
helm --namespace promtail upgrade --atomic --create-namespace --install promtail grafana/promtail --values promtail/values.yaml
```

## Add Loki to Grafana
After all pods are ready, you can add Loki as a datasource in Grafana.
Go to your Grafana page, login with username `admin`, password `admin`. Then add Loki as a datasource.
The URL is the `http://loki-loki-distributed-gateway.loki.svc.cluster.local`, then enable `basic auth` in `Auth` section, put
`loki` as username, and `password` as password, and then click `Save & Test`.

Now you should see logs in your loki datasource.
