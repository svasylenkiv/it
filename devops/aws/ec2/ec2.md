# Як отримати AMI Name по EC2 інстансу
📦 Через AWS CLI (2 кроки в одному):

```bash
aws ec2 describe-instances \
  --instance-ids i-xxxxxxxxxxxxxxxxx \
  --query "Reservations[*].Instances[*].ImageId" \
  --output text \
  --region us-east-1
```

→ Отримаєш: ami-xxxxxxxxxxxxxxxxx

```bash
aws ec2 describe-images \
  --image-ids ami-xxxxxxxxxxxxxxxxx \
  --query "Images[0].Name" \
  --output text \
  --region us-east-1
```

✅ Відповідь буде: al2023-ami-2023.4.20240611.0-kernel-6.1-x86_64