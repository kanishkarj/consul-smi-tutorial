#!/usr/bin/bash

helm repo add hashicorp https://helm.releases.hashicorp.com;
helm install consul hashicorp/consul -f ./values.yaml;
CONSUL_SERVER_IP=$(kubectl get service consul-consul-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}');
export CONSUL_HTTP_ADDR=http://$CONSUL_SERVER_IP:80;
export CONSUL_HTTP_TOKEN=$(kubectl get secrets consul-consul-bootstrap-acl-token --template={{.data.token}} | base64 -d);
kubectl create secret generic consul-smi-acl-token --from-literal=token=$CONSUL_HTTP_TOKEN;
kubectl apply -f ./consul-smi-controller.yml;
kubectl apply -f ./crd.yml;