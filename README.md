# MLA
**Work in progress** implementation of User Cluster MLA (Monitoring Logging & Alerting) for KKP.

### Requirements
At least 2 clusters:
 - for the "Seed Cluster": 4 CPUs, 16 Gi of RAM (e.g. `T3A.xlarge`)
 - for the "User Cluster": 1 CPU, 2 Gi or RAM (e.g. `T3A.small`)

(optionally, User Cluster components can be installed into the Seed Cluster for testing with 1 cluster as well)

### Deploy Seed Cluster Components
```bash
./deploy-seed.sh
```

### Deploy Tenant MLA Gateway(s) in Seed Cluster
```bash
./deploy-tenant-gateway.sh abc

./deploy-tenant-gateway.sh xyz
```

### Deploy User Cluster Components
Get External IP of the MLA Gateway in "Seed Cluster":
```bash
kubectl get svc mla-gateway-ext -n cluster-abc
```

Use that to deploy User Cluster components to a different cluster:
```bash
./deploy-user-cluster.sh a54afbcdd28d5404f940d382362b2e06-2091261264.eu-central-1.elb.amazonaws.com
```

### Add Loki and Prometheus to Grafana
After all pods are ready, you can add Loki as a datasource in Grafana.
Go to your Grafana page, login with username `admin`, password `admin`.
Then add Loki as a datasource.
The URL is `http://mla-gateway.cluster-xyz.svc.cluster.local`. Click `Save & Test`.
For Prometheus, the URL is `http://mla-gateway.cluster-xyz.svc.cluster.local/api/prom`.

### Check Alertmanager UI
Currently, to be able to see the Alertmanager UI, we need to create a alertmanager configuration first:
```bash
./create-alert-config.sh  a24c848bd4d914cdcbbc7c860f4fe9d4-1893886320.eu-central-1.elb.amazonaws.com tenant-2
```
The first argument is the address of **mla-gateway-alert**, and the second argument is used for creating the receiver 
in Alertmanger configuration.

After this, you should be able to see the alertmanager UI at:
`http://<mla-gateway-alert adress>/api/prom/alertmanager`.
