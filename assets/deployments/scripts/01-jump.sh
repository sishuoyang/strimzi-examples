#!/bin/sh
vpc_name="eksctl-sishuo-eks-cluster/VPC"
ami_id="ami-045054d637e984329" # jump machine
SECURITY_GROUP_NAME="sishuo-ssh-jump"
HOSTED_ZONE_ID="Z267DABJTL4JFI"
KEY_NAME="sishuo-keypair-sg"
##### Step 1 Get the EKS cluster VPC Id
vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${vpc_name}" --query "Vpcs[0].VpcId" --output text)

echo "vpc id:${vpc_id}"

##### Step 2 Create security group that allows ssh
# Check if security group already exists
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

echo "Security group id is:${SECURITY_GROUP_ID}"

# If the security group doesn't exist, create a new one
if [ "$SECURITY_GROUP_ID" == "None" ]; then
  SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name "$SECURITY_GROUP_NAME" --description "Security group for SSH access from my IP" --vpc-id "$vpc_id" --output text)
  aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 22 --cidr "$(curl -s https://checkip.amazonaws.com)/32"
  echo "Created security group: $SECURITY_GROUP_ID"

    # Authorize SSH access from your current public IP
    MY_IP=$(curl -s http://checkip.amazonaws.com)
    aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr $MY_IP/32
else
  echo "Security group already exists: $SECURITY_GROUP_ID"
fi
echo "Security group id is:${SECURITY_GROUP_ID}"



##### Step 3 start my jump machine
# Find a subnet in the VPC with "Auto-assign public IPv4 address" set to true
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" "Name=map-public-ip-on-launch,Values=true" --query "Subnets[0].SubnetId" --output text)

echo "subnet id is: $SUBNET_ID"

# Start the EC2 instance
INSTANCE_ID=$(aws ec2 run-instances --image-id "$ami_id" --instance-type t3.micro --key-name "$KEY_NAME" --security-group-ids "$SECURITY_GROUP_ID" --subnet-id "$SUBNET_ID" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=sishuo-jump}]" --output text --query "Instances[0].InstanceId")

##### Step 4 Wait for instance running
echo "Starting instance: $INSTANCE_ID"

# Wait for the instance to reach the running state
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Get the public IP address of the instance
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

##### Step 5 Update DNS record
echo "updating DNS record to ip ${PUBLIC_IP}"
aws route53 change-resource-record-sets \
    --hosted-zone-id ${HOSTED_ZONE_ID} \
    --change-batch '{
    "Changes": [
        {
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "jump.sishuo.ps.confluent-internal.io",
            "Type": "A",
            "TTL": 60,
            "ResourceRecords": [
            {
                "Value": "'"$PUBLIC_IP"'"
            }
            ]
        }
        }
    ]
    }' > /dev/null