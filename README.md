# Consul SMI Tutorial

This guide has been tested on GKE with kube master-version 1.14.10

### Prereq

Install Kubctl, helm and consul cli.

### Instructions 

```shell
# Adds the helm-chart for consul
helm repo add hashicorp https://helm.releases.hashicorp.com

# Install consul on the cluster(GKE)
helm install consul hashicorp/consul -f ./values.yaml

# Install consul on the cluster(Minikube)
helm install consul hashicorp/consul -f ./values-mini.yaml
```

Extract the IP:Port of the consul-consul-ui service. And execute the following command to Configure consul cli:

```shell
export CONSUL_HTTP_ADDR=http://<IP>:<PORT>
```

Extract the consul ACL bootstrap token. Then configure and test consul acl:
```shell
kubectl get secrets consul-consul-bootstrap-acl-token --template={{.data.token}} | base64 -d
# copy the token output from above command

# fill in the token below
export CONSUL_HTTP_TOKEN=<TOKEN>

# if following command output contains a list of tokens and their details, then we are good to go 
consul acl token list

# if the following command works go ahead to execute the following command to create a secret that SMI adapter will need.
kubectl create secret generic consul-smi-acl-token--from-literal=token=<TOKEN>

kubectl get all
# verify if everything is working now.
```

Deloy the app:
```shell
# GKE (support for loadbalancer in service type)
kubectl apply -f ./example-app.yml

# In case of minikube
kubectl apply -f ./example-app-mini.yml
```

Now ideally your service should be visible in the consul UI. You can extact the dashboard service and you should see "-1" on the page and that `Counting Service is Unreachable`.

To enable the connection create a TrafficSpec and TrafficTarget.
```shell
kubectl apply -f ./traffic-target.yml
```

Open the dashboard and refresh it, you should see it working. Also you can see a new `intention` is created in the consul-ui page.

To disable the connection delete the CRDs created above.
```shell
kubectl delete -f ./traffic-target.yml
```

The page should not work anymore.