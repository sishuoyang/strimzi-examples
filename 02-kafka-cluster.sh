#!/bin/bash

## Change the namespace
echo "==============changing namespace=============="
sed -i '' 's/namespace: .*/namespace: sishuo-cluster/' ./strimzi-0.33.2/install/cluster-operator/*RoleBinding*.yaml

kubectl create namespace sishuo-cluster

echo "==============Install Strimzi Operator=============="
kubectl create -f ./strimzi-0.33.2/install/cluster-operator -n sishuo-cluster

echo "==============deploy kafka cluster=============="

kubectl create -f ./assets/deployments/00-kafka.yml -n sishuo-cluster
kubectl config set-context --current --namespace=sishuo-cluster


echo "==============deploy Prometheus=============="
# https://strimzi.io/docs/operators/latest/deploying.html#proc-metrics-deploying-prometheus-operator-str
kubectl create -f ./assets/deployments/01-prometheus-operator.yaml -n sishuo-cluster
kubectl apply -f ./assets/deployments/00-prometheus-additional.yaml -n sishuo-cluster
kubectl apply -f ./assets/deployments/01-prometheus-pod-monitor.yaml -n sishuo-cluster
kubectl apply -f ./assets/deployments/02-prometheus-rules.yaml -n sishuo-cluster
kubectl apply -f ./assets/deployments/03-prometheus.yaml -n sishuo-cluster


echo "==============deploy Grafana=============="
kubectl apply -f ./assets/deployments/04-grafana.yaml -n sishuo-cluster
kubectl get service grafana


