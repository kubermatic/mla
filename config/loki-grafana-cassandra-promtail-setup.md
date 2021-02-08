# Loki setup
This guide is about installing Loki, Promtail, and Grafana in a single Kubernetes cluster by using 
[Grafana official helm charts](https://github.com/grafana/helm-charts).

## Prerequisite
Before you start, make sure to add the chart repo to Helm:
```bash
helm repo add grafana https://grafana.github.io/helm-charts
```

### Install Cassandra Database in Kubernetes cluster
Currently Cassandra is used for both index and chunk storage for logs.  
[Cassandra manifests](cassandra) are originally from [Scalable-Cassandra-deployment-on-Kubernetes](https://github.com/IBM/Scalable-Cassandra-deployment-on-Kubernetes), the only changes are:
- Change `StorageClassName` to `standard-v2` for AWS usage.  
  For install it, just run:
 ```bash
kubectl apply -f cassandra/
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