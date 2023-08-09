#! /bin/bash

set -e

PROFILE="temp"

AWS_ACCESS_KEY_ID="$1"
AWS_SECRET_ACCESS_KEY="$2"
aws configure --profile $PROFILE set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure --profile $PROFILE set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure --profile $PROFILE set region us-east-1
aws configure --profile $PROFILE set output json

REPO_NAME="$3"
if [ ! -d "./deployments/$REPO_NAME" ]; then
  mkdir -p ./deployments/$REPO_NAME
fi

aws ec2 --profile $PROFILE describe-instances \
  --filters "Name=tag:Name,Values=${REPO_NAME}" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].InstanceId" >./deployments/$REPO_NAME/ec2_list.json

if [ ! -z "$(jq -r '.[]' ./deployments/$REPO_NAME/ec2_list.json)" ]; then
  echo "Instance already exists"
  exit 0
fi

aws ec2 --profile $PROFILE create-key-pair --key-name ${REPO_NAME} --query 'KeyMaterial' --output text >./deployments/$REPO_NAME/${REPO_NAME}.pem
echo "Created key pair ./deployments/$REPO_NAME/${REPO_NAME}, add it to github secrets"

VPC_ID=$(aws ec2 --profile $PROFILE describe-vpcs | jq -r '.Vpcs[0].VpcId')

SG_ID=$(aws ec2 --profile $PROFILE create-security-group \
  --group-name "${REPO_NAME}" \
  --description "Security group for ${REPO_NAME} deployment" \
  --vpc-id ${VPC_ID} | jq -r '.GroupId')

for port in 22 80 443; do
  aws ec2 --profile $PROFILE authorize-security-group-ingress \
    --group-id ${SG_ID} \
    --protocol tcp \
    --port ${port} \
    --cidr 0.0.0.0/0 >/dev/null
done

SUBNET_ID=$(aws ec2 --profile $PROFILE describe-subnets | jq -r '.Subnets[] | select(.AvailabilityZone == "us-east-1a").SubnetId')

aws ec2 --profile $PROFILE run-instances \
  --image-id ami-053b0d53c279acc90 \
  --count 1 \
  --instance-type t2.micro \
  --key-name ${REPO_NAME} \
  --security-group-ids ${SG_ID} \
  --subnet-id ${SUBNET_ID} \
  --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":20,"DeleteOnTermination":true,"VolumeType":"gp2"}}]' \
  --tag-specifications "ResourceType='instance',Tags=[{Key='Name',Value='${REPO_NAME}'}]"

sleep 120
