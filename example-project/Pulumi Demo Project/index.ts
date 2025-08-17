import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// Конфігурація проекту
const config = new pulumi.Config();
const environment = config.require("environment");
const projectName = config.get("projectName") || "pulumi-demo";

// Загальні теги для всіх ресурсів
const commonTags = {
    Environment: environment,
    Project: projectName,
    ManagedBy: "pulumi",
    CreatedBy: "pulumi-guide",
};

// Створення VPC
const vpc = new aws.ec2.Vpc("main-vpc", {
    cidrBlock: "10.0.0.0/16",
    enableDnsHostnames: true,
    enableDnsSupport: true,
    tags: {
        Name: `${projectName}-vpc`,
        ...commonTags,
    },
});

// Створення Internet Gateway
const internetGateway = new aws.ec2.InternetGateway("main-igw", {
    vpcId: vpc.id,
    tags: {
        Name: `${projectName}-igw`,
        ...commonTags,
    },
});

// Створення публічної підмережі
const publicSubnet = new aws.ec2.Subnet("public-subnet", {
    vpcId: vpc.id,
    cidrBlock: "10.0.1.0/24",
    availabilityZone: "us-west-2a",
    mapPublicIpOnLaunch: true,
    tags: {
        Name: `${projectName}-public-subnet`,
        ...commonTags,
    },
});

// Таблиця маршрутизації для публічної підмережі
const publicRouteTable = new aws.ec2.RouteTable("public-rt", {
    vpcId: vpc.id,
    routes: [{
        cidrBlock: "0.0.0.0/0",
        gatewayId: internetGateway.id,
    }],
    tags: {
        Name: `${projectName}-public-rt`,
        ...commonTags,
    },
});

// Прив'язка таблиці маршрутизації до підмережі
const publicRouteTableAssociation = new aws.ec2.RouteTableAssociation("public-rta", {
    subnetId: publicSubnet.id,
    routeTableId: publicRouteTable.id,
});

// Security Group для веб-сервера
const webSecurityGroup = new aws.ec2.SecurityGroup("web-sg", {
    vpcId: vpc.id,
    description: "Security group for web server",
    ingress: [
        {
            description: "HTTP",
            fromPort: 80,
            toPort: 80,
            protocol: "tcp",
            cidrBlocks: ["0.0.0.0/0"],
        },
        {
            description: "HTTPS",
            fromPort: 443,
            toPort: 443,
            protocol: "tcp",
            cidrBlocks: ["0.0.0.0/0"],
        },
        {
            description: "SSH",
            fromPort: 22,
            toPort: 22,
            protocol: "tcp",
            cidrBlocks: ["0.0.0.0/0"],
        },
    ],
    egress: [
        {
            fromPort: 0,
            toPort: 0,
            protocol: "-1",
            cidrBlocks: ["0.0.0.0/0"],
        },
    ],
    tags: {
        Name: `${projectName}-web-sg`,
        ...commonTags,
    },
});

// Створення S3 bucket для логів
const logsBucket = new aws.s3.Bucket("logs-bucket", {
    tags: {
        Name: `${projectName}-logs`,
        ...commonTags,
    },
});

// Налаштування S3 bucket для логування
const logsBucketVersioning = new aws.s3.BucketVersioning("logs-versioning", {
    bucket: logsBucket.id,
    versioningConfiguration: {
        status: "Enabled",
    },
});

// EC2 Instance для веб-сервера
const webServer = new aws.ec2.Instance("web-server", {
    instanceType: "t2.micro",
    ami: "ami-0c55b159cbfafe1f0", // Amazon Linux 2 AMI
    subnetId: publicSubnet.id,
    vpcSecurityGroupIds: [webSecurityGroup.id],
    keyName: config.get("keyName"), // Опціонально: ім'я SSH ключа
    userData: pulumi.interpolate`#!/bin/bash
# Оновлення системи
yum update -y

# Встановлення Apache
yum install -y httpd

# Запуск Apache
systemctl start httpd
systemctl enable httpd

# Створення веб-сторінки
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Pulumi Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background: #0066cc; color: white; padding: 20px; border-radius: 5px; }
        .content { margin-top: 20px; }
        .info { background: #f0f0f0; padding: 15px; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Pulumi Infrastructure as Code Demo</h1>
        </div>
        <div class="content">
            <h2>Welcome to your Pulumi-managed infrastructure!</h2>
            <div class="info">
                <h3>Infrastructure Details:</h3>
                <ul>
                    <li><strong>Environment:</strong> ${environment}</li>
                    <li><strong>Project:</strong> ${projectName}</li>
                    <li><strong>Instance Type:</strong> t2.micro</li>
                    <li><strong>Region:</strong> us-west-2</li>
                    <li><strong>Managed By:</strong> Pulumi</li>
                </ul>
            </div>
            <div class="info">
                <h3>What's deployed:</h3>
                <ul>
                    <li>✅ VPC with public subnet</li>
                    <li>✅ Internet Gateway</li>
                    <li>✅ Security Groups</li>
                    <li>✅ EC2 Instance with Apache</li>
                    <li>✅ S3 Bucket for logs</li>
                </ul>
            </div>
            <p><em>This infrastructure was created using Pulumi on Windows 11!</em></p>
        </div>
    </div>
</body>
</html>
EOF

# Налаштування логування в S3
yum install -y aws-cli

# Створення скрипта для логування
cat > /usr/local/bin/log-to-s3.sh << 'EOF'
#!/bin/bash
BUCKET_NAME="${logsBucket.bucket}"
LOG_FILE="/var/log/httpd/access_log"
DATE=$(date +%Y-%m-%d)

# Копіювання логів в S3
aws s3 cp $LOG_FILE s3://$BUCKET_NAME/logs/$DATE/access_log --region us-west-2
EOF

chmod +x /usr/local/bin/log-to-s3.sh

# Додавання cron job для щоденного логування
echo "0 2 * * * /usr/local/bin/log-to-s3.sh" | crontab -

echo "Web server setup completed!"
`,
    tags: {
        Name: `${projectName}-web-server`,
        ...commonTags,
    },
});

// Еластичний IP для веб-сервера
const webServerEip = new aws.ec2.Eip("web-server-eip", {
    instance: webServer.id,
    vpc: true,
    tags: {
        Name: `${projectName}-web-server-eip`,
        ...commonTags,
    },
});

// Експорт важливих значень
export const vpcId = vpc.id;
export const publicSubnetId = publicSubnet.id;
export const webServerPublicIp = webServerEip.publicIp;
export const webServerPublicDns = webServer.publicDns;
export const logsBucketName = logsBucket.bucket;
export const webServerUrl = pulumi.interpolate`http://${webServerEip.publicIp}`;
export const sshCommand = pulumi.interpolate`ssh -i your-key.pem ec2-user@${webServerEip.publicIp}`; 