#!/bin/bash

set -e

# === 🔧 КОЛЬОРИ ===
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# === 📦 ЗМІННІ ===
REGION="us-east-1"
PROJECT="myapp"
ENV="dev"

CLUSTER_NAME="$PROJECT-$ENV-cluster"
REPO_NAME="$PROJECT-$ENV-ecr"
TASK_NAME="$PROJECT-$ENV-task"
SERVICE_NAME="$PROJECT-$ENV-service"
CONTAINER_NAME="$PROJECT-container"
CONTAINER_PORT=80
ROLE_NAME="ecsTaskExecutionRole"

# === 🔑 Отримання AWS Account ID ===
echo -e "${GREEN}🔑 Отримання AWS Account ID...${NC}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

echo -e "${GREEN}🚀 Старт деплою ECS Fargate для $PROJECT ($ENV)...${NC}"

# === 🔐 Перевірка чи роль вже існує ===
echo -e "${GREEN}🔐 Створення IAM ролі для ECS Task Execution (якщо не існує)...${NC}"
if ! aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "ecs-tasks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }'
  
  aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
fi

EXEC_ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query "Role.Arn" --output text)

# === 🐳 ECR ===
echo -e "${GREEN}📦 Створення ECR репозиторію...${NC}"
aws ecr describe-repositories --repository-names "$REPO_NAME" --region "$REGION" > /dev/null 2>&1 || \
aws ecr create-repository --repository-name "$REPO_NAME" --region "$REGION"

# === ☁️ ECS Кластер ===
echo -e "${GREEN}📦 Створення ECS кластеру...${NC}"
aws ecs describe-clusters --clusters "$CLUSTER_NAME" --region "$REGION" | grep "ACTIVE" > /dev/null || \
aws ecs create-cluster --cluster-name "$CLUSTER_NAME" --region "$REGION"

# === 🌐 VPC ===
echo -e "${GREEN}🌐 Створення VPC і сабнетів...${NC}"
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region "$REGION" --query 'Vpc.VpcId' --output text)
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames

SUBNET1_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block 10.0.1.0/24 --availability-zone "$REGION"a --query 'Subnet.SubnetId' --output text)
SUBNET2_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block 10.0.2.0/24 --availability-zone "$REGION"b --query 'Subnet.SubnetId' --output text)

IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"

RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id "$RT_ID" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID"

aws ec2 associate-route-table --subnet-id "$SUBNET1_ID" --route-table-id "$RT_ID"
aws ec2 associate-route-table --subnet-id "$SUBNET2_ID" --route-table-id "$RT_ID"

# === 🔐 Security Group ===
echo -e "${GREEN}🔐 Створення security group...${NC}"
SG_ID=$(aws ec2 create-security-group --group-name "$PROJECT-$ENV-sg" --description "Allow HTTP" --vpc-id "$VPC_ID" --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port $CONTAINER_PORT --cidr 0.0.0.0/0

# === 📄 Task Definition ===
echo -e "${GREEN}📄 Створення ECS Task Definition...${NC}"
cat <<EOF > task-def.json
{
  "family": "$TASK_NAME",
  "executionRoleArn": "$EXEC_ROLE_ARN",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "$CONTAINER_NAME",
      "image": "$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest",
      "portMappings": [
        {
          "containerPort": $CONTAINER_PORT,
          "protocol": "tcp"
        }
      ],
      "essential": true
    }
  ]
}
EOF

aws ecs register-task-definition \
  --cli-input-json file://task-def.json \
  --region "$REGION"

# === 🚀 ECS Service ===
echo -e "${GREEN}🚀 Створення ECS сервісу...${NC}"
aws ecs create-service \
  --cluster "$CLUSTER_NAME" \
  --service-name "$SERVICE_NAME" \
  --task-definition "$TASK_NAME" \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET1_ID,$SUBNET2_ID],securityGroups=[$SG_ID],assignPublicIp=ENABLED}" \
  --region "$REGION"

echo -e "${GREEN}✅ Деплой завершено успішно!${NC}"
