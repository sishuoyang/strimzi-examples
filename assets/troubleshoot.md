## Troubleshoot

### EBS cannot be provisioned
```bash
kubectl describe pvc data-zookeeper-1

Warning  ProvisioningFailed  8s                ebs.csi.aws.com_ebs-csi-controller-74456dbff-6xrjn_15bb87a3-5099-4e56-af2a-d9542b45d9e5  failed to provision volume with StorageClass "gp2": rpc error: code = Internal desc = Could not create volume "pvc-10ee6dda-588f-48ef-b7a1-0e566dca988d": could not create volume in EC2: WebIdentityErr: failed to retrieve credentials
caused by: AccessDenied: Not authorized to perform sts:AssumeRoleWithWebIdentity
```

Check CSI service account role
```bash
kubectl describe sa ebs-csi-controller-sa -n kube-system
# make sure the annotation has the correct Role
Name:                ebs-csi-controller-sa
Namespace:           kube-system
Labels:              app.kubernetes.io/component=csi-driver
                     app.kubernetes.io/managed-by=EKS
                     app.kubernetes.io/name=aws-ebs-csi-driver
                     app.kubernetes.io/version=1.16.1
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::492737776546:role/AmazonEKS_EBS_CSI_DriverRole
```

Login to AWS IAM console to check the role
* check it has the "AwsEBSCSIDriverPolicy" policy attached
* Check the trusted entities, the oidc provider URL should match the `OpenID Connect provider URL` in your EKS cluster overview page.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::492737776546:oidc-provider/oidc.eks.ap-southeast-1.amazonaws.com/id/AC64D132952805651C49CC6E12568A48"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.ap-southeast-1.amazonaws.com/id/AC64D132952805651C49CC6E12568A48:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
```