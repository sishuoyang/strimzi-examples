#!/bin/bash

VPC_NAME=eksctl-sishuo-eks-cluster/VPC

echo echo "==============remove load balancers=============="
# Find all load balancer resources from "kubectl get service" command
LB_RESOURCES=$(kubectl get service -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | .status.loadBalancer.ingress[].hostname')
echo "Load balancers are:${LB_RESOURCES}"


# Delete these load balancer resources in AWS
for lb in $LB_RESOURCES; do
    echo "Deleting load balancer: $lb"
    lb_name=$(echo "$lb" | cut -d'-' -f1)
    aws elb delete-load-balancer --load-balancer-name "$lb_name"
done

echo "==============remove kafka=============="
kubectl delete -f ./deployments/03-prometheus.yaml -n sishuo-cluster
kubectl delete -f ./deployments/02-prometheus-rules.yaml -n sishuo-cluster
kubectl delete -f ./deployments/01-prometheus-pod-monitor.yaml -n sishuo-cluster
kubectl delete -f ./deployments/00-prometheus-additional.yaml -n sishuo-cluster
kubectl delete -f ./deployments/00-kafka.yml


kubectl delete -f ./deployments/04-grafana.yaml -n sishuo-cluster


echo "==============remove operator=============="
kubectl delete -f ../strimzi-0.33.2/install/cluster-operator -n sishuo-cluster
kubectl delete -f ./deployments/01-prometheus-operator.yaml -n sishuo-cluster

echo "==============delete ebs-csi-controller=============="
kubectl delete poddisruptionbudget ebs-csi-controller -n kube-system 

echo "==============delete clusterr=============="
eksctl delete cluster -f ../00-common/00-default-cluster.yaml


VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --query "Vpcs[0].VpcId" --output text)

echo "==============delete VPC=============="
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "==============delete CloudFormation Stack=============="π
aws cloudformation delete-stack --stack-name eksctl-sishuo-eks-cluster
