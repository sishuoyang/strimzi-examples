#!/bin/sh
export CLUSTER_NAME="sishuo-eks"

eksctl create cluster -f ./assets/deployments/00-default-cluster.yaml

output=$(kubectl describe sa ebs-csi-controller-sa -n kube-system | grep eks.amazonaws.com/role-arn)

echo "Role for service account is: ${output}"
# Extract the value after "role-arn:"
role_arn=${output#*"role-arn: "}
echo "Role for service account is: ${role_arn}"
# Print the extracted value
echo "$role_arn"


#Install CSI
eksctl create addon \
--name aws-ebs-csi-driver \
--cluster ${CLUSTER_NAME} \
--service-account-role-arn ${role_arn} \
--force
