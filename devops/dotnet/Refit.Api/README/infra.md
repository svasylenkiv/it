✅ 1. Змінні
```bash
# === БАЗОВІ ЗМІННІ ===
# ACCOUNT_ID можна отримати командою:
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
# export AWS_ACCOUNT_ID="123456789012"
export PROJECT="refitapi"
export REGION="us-east-1"
export ENV="dev"
export CONTAINER_PORT="8080"

# === ІМЕНА РЕСУРСІВ ===
export REPO_NAME="$PROJECT-ecr"
export CLUSTER_NAME="$PROJECT-$ENV-cluster"
export TASK_NAME="$PROJECT-$ENV-task"
export SERVICE_NAME="$PROJECT-$ENV-service"
export CONTAINER_NAME="$PROJECT-container"
export VPC_NAME="$PROJECT-$ENV-vpc"
```

🐳 2. Створення ECR-репозиторію
```bash
aws ecr create-repository \
  --repository-name "$REPO_NAME" \
  --region "$REGION"
```

☁️ 3. Створення ECS-кластеру
```bash
aws ecs create-cluster \
  --cluster-name "$CLUSTER_NAME" \
  --region "$REGION"
```

🌐 4. Створення VPC + субнетів (спрощено)
```bash
# VPC
export VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --region "$REGION" \
  --query 'Vpc.VpcId' --output text)

# Відключення DNS hostnames
aws ec2 modify-vpc-attribute \
  --vpc-id "$VPC_ID" \
  --enable-dns-hostnames

# Публічні сабнети
export SUBNET1_ID=$(aws ec2 create-subnet \
  --vpc-id "$VPC_ID" --cidr-block 10.0.1.0/24 \
  --availability-zone "$REGION"a \
  --query 'Subnet.SubnetId' --output text)

export SUBNET2_ID=$(aws ec2 create-subnet \
  --vpc-id "$VPC_ID" --cidr-block 10.0.2.0/24 \
  --availability-zone "$REGION"b \
  --query 'Subnet.SubnetId' --output text)

# Internet Gateway
export IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' --output text)

aws ec2 attach-internet-gateway \
  --internet-gateway-id "$IGW_ID" \
  --vpc-id "$VPC_ID"

# Маршрутна таблиця
export RT_ID=$(aws ec2 create-route-table \
  --vpc-id "$VPC_ID" \
  --query 'RouteTable.RouteTableId' --output text)

aws ec2 create-route \
  --route-table-id "$RT_ID" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "$IGW_ID"

# Асоціація сабнетів
aws ec2 associate-route-table \
  --subnet-id "$SUBNET1_ID" \
  --route-table-id "$RT_ID"

aws ec2 associate-route-table \
  --subnet-id "$SUBNET2_ID" \
  --route-table-id "$RT_ID"
```

🔐 5. Security Group
```bash
export SG_ID=$(aws ec2 create-security-group \
  --group-name "$PROJECT-$ENV-sg" \
  --description "Allow HTTP for ECS" \
  --vpc-id "$VPC_ID" \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp --port 80 --cidr 0.0.0.0/0
```

📦 6. Створення ECS Task Definition (JSON-файл)
Створи файл task-def.json:

Створи файл task-def.json:

```bash
echo "📄 Створення файлу task-def.json..."
cat > task-def.json <<EOF
{
  "family": "${TASK_NAME}",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "${CONTAINER_NAME}",
      "image": "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:latest",
      "portMappings": [
        {
          "containerPort": ${CONTAINER_PORT},
          "protocol": "tcp"
        }
      ],
      "essential": true
    }
  ]
}
EOF
```

Потім зареєструй:

```bash
envsubst < task-def.json > rendered-task-def.json

aws ecs register-task-definition \
  --cli-input-json file://rendered-task-def.json \
  --region "$REGION"
```

🚀 7. Створення ECS-сервісу
```bash
aws ecs create-service \
  --cluster "$CLUSTER_NAME" \
  --service-name "$SERVICE_NAME" \
  --task-definition "$TASK_NAME" \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET1_ID,$SUBNET2_ID],securityGroups=[$SG_ID],assignPublicIp=ENABLED}" \
  --region "$REGION"
```
