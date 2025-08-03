# Гід по Pulumi на Windows 11

## Що таке Pulumi?

Pulumi - це інфраструктура як код (IaC) платформа, яка дозволяє створювати, розгортати та керувати хмарною інфраструктурою за допомогою звичайних мов програмування (Python, TypeScript, Go, C#, Java).

## Встановлення Pulumi на Windows 11

### 1. Встановлення через PowerShell

Відкрийте PowerShell від імені адміністратора та виконайте:

```powershell
# Встановлення через winget (рекомендований спосіб)
winget install Pulumi.Pulumi

# Або через Chocolatey
choco install pulumi

# Або через Scoop
scoop install pulumi
```

### 2. Встановлення через офіційний інсталятор

1. Перейдіть на [pulumi.com](https://www.pulumi.com/docs/install/)
2. Завантажте Windows інсталятор (.msi файл)
3. Запустіть інсталятор та слідуйте інструкціям

### 3. Перевірка встановлення

```powershell
pulumi version
```

## Налаштування середовища

### 1. Встановлення Node.js (для TypeScript/JavaScript)

```powershell
# Встановлення Node.js через winget
winget install OpenJS.NodeJS

# Перевірка версії
node --version
npm --version
```

### 2. Встановлення Python (для Python)

```powershell
# Встановлення Python через winget
winget install Python.Python.3.11

# Перевірка версії
python --version
pip --version
```

### 3. Встановлення Git

```powershell
# Встановлення Git через winget
winget install Git.Git

# Перевірка версії
git --version
```

## Перші кроки з Pulumi

### 1. Створення нового проекту

```powershell
# Створення директорії для проекту
mkdir my-pulumi-project
cd my-pulumi-project

# Ініціалізація нового Pulumi проекту
pulumi new aws-typescript  # для AWS з TypeScript
# або
pulumi new azure-python    # для Azure з Python
# або
pulumi new gcp-go         # для GCP з Go
```

### 2. Структура проекту

Після ініціалізації ви отримаєте:

```
my-pulumi-project/
├── Pulumi.yaml          # Конфігурація проекту
├── Pulumi.dev.yaml      # Конфігурація для dev середовища
├── index.ts             # Основний код (TypeScript)
├── package.json         # Залежності Node.js
└── tsconfig.json        # Конфігурація TypeScript
```

### 3. Налаштування хмарного провайдера

#### AWS
```powershell
# Встановлення AWS CLI
winget install Amazon.AWSCLI

# Налаштування AWS credentials
aws configure
```

#### Azure
```powershell
# Встановлення Azure CLI
winget install Microsoft.AzureCLI

# Вхід в Azure
az login
```

#### GCP
```powershell
# Встановлення Google Cloud SDK
# Завантажте з https://cloud.google.com/sdk/docs/install

# Ініціалізація
gcloud init
```

## Перший проект: Створення S3 bucket (AWS)

### 1. Створення проекту

```powershell
mkdir my-first-pulumi
cd my-first-pulumi
pulumi new aws-typescript
```

### 2. Редагування коду

Відкрийте `index.ts` та замініть вміст:

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// Створення S3 bucket
const bucket = new aws.s3.Bucket("my-bucket", {
    tags: {
        Environment: "dev",
        Project: "pulumi-demo",
    },
});

// Експорт URL bucket
export const bucketName = bucket.id;
export const bucketUrl = bucket.websiteEndpoint;
```

### 3. Встановлення залежностей

```powershell
npm install
```

### 4. Превью змін

```powershell
pulumi preview
```

### 5. Розгортання

```powershell
pulumi up
```

### 6. Перегляд ресурсів

```powershell
pulumi stack output
```

## Основні команди Pulumi

```powershell
# Перегляд змін перед розгортанням
pulumi preview

# Розгортання інфраструктури
pulumi up

# Видалення ресурсів
pulumi destroy

# Перегляд стану стеку
pulumi stack

# Перегляд ресурсів
pulumi stack output

# Перегляд логів
pulumi logs

# Зміна конфігурації
pulumi config set aws:region us-west-2

# Перегляд конфігурації
pulumi config
```

## Робота зі стеками

### Створення нового стеку

```powershell
pulumi stack init production
```

### Переключення між стеками

```powershell
pulumi stack select dev
pulumi stack select production
```

### Експорт/Імпорт стеку

```powershell
# Експорт
pulumi stack export --file stack.json

# Імпорт
pulumi stack import --file stack.json
```

## Приклади проектів

### 1. Веб-сервер на EC2 (AWS)

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// VPC
const vpc = new aws.ec2.Vpc("main", {
    cidrBlock: "10.0.0.0/16",
    enableDnsHostnames: true,
    enableDnsSupport: true,
});

// Subnet
const subnet = new aws.ec2.Subnet("main", {
    vpcId: vpc.id,
    cidrBlock: "10.0.1.0/24",
    availabilityZone: "us-west-2a",
});

// Security Group
const sg = new aws.ec2.SecurityGroup("web-sg", {
    vpcId: vpc.id,
    ingress: [{
        protocol: "tcp",
        fromPort: 80,
        toPort: 80,
        cidrBlocks: ["0.0.0.0/0"],
    }, {
        protocol: "tcp",
        fromPort: 22,
        toPort: 22,
        cidrBlocks: ["0.0.0.0/0"],
    }],
    egress: [{
        protocol: "-1",
        fromPort: 0,
        toPort: 0,
        cidrBlocks: ["0.0.0.0/0"],
    }],
});

// EC2 Instance
const instance = new aws.ec2.Instance("web-server", {
    instanceType: "t2.micro",
    ami: "ami-0c55b159cbfafe1f0", // Amazon Linux 2
    subnetId: subnet.id,
    vpcSecurityGroupIds: [sg.id],
    userData: `#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from Pulumi!</h1>" > /var/www/html/index.html`,
});

export const publicIp = instance.publicIp;
export const publicDns = instance.publicDns;
```

### 2. Kubernetes кластер (EKS)

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as eks from "@pulumi/eks";

// Створення EKS кластера
const cluster = new eks.Cluster("my-cluster", {
    version: "1.24",
    instanceType: "t3.medium",
    desiredCapacity: 2,
    minSize: 1,
    maxSize: 3,
    nodeRootVolumeSize: 20,
});

export const kubeconfig = cluster.kubeconfig;
export const clusterName = cluster.eksCluster.name;
```

## Найкращі практики

### 1. Організація коду

```
project/
├── src/
│   ├── networking/
│   ├── compute/
│   ├── storage/
│   └── security/
├── config/
├── scripts/
└── docs/
```

### 2. Використання конфігурації

```typescript
const config = new pulumi.Config();
const environment = config.require("environment");
const instanceType = config.get("instanceType") || "t2.micro";
```

### 3. Тегування ресурсів

```typescript
const commonTags = {
    Environment: environment,
    Project: "my-project",
    ManagedBy: "pulumi",
};

const bucket = new aws.s3.Bucket("my-bucket", {
    tags: commonTags,
});
```

### 4. Використання модулів

```typescript
// networking/vpc.ts
export function createVpc(name: string, cidr: string) {
    return new aws.ec2.Vpc(name, {
        cidrBlock: cidr,
        enableDnsHostnames: true,
        enableDnsSupport: true,
    });
}

// index.ts
import { createVpc } from "./networking/vpc";
const vpc = createVpc("main", "10.0.0.0/16");
```

## Налагодження та логування

### 1. Детальне логування

```powershell
pulumi up --verbose=3
```

### 2. Перегляд ресурсів

```powershell
pulumi stack --show-urns
```

### 3. Тестування

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as assert from "assert";

// Тест конфігурації
pulumi.runtime.registerStackTransformation((args) => {
    if (args.type === "aws:s3/bucket:Bucket") {
        assert.ok(args.props.tags, "Bucket must have tags");
    }
    return { props: args.props, opts: args.opts };
});
```

## Інтеграція з CI/CD

### GitHub Actions

```yaml
name: Pulumi
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '16'
    
    - name: Setup Pulumi
      uses: pulumi/setup-pulumi@v1
    
    - name: Install dependencies
      run: npm install
    
    - name: Preview changes
      run: pulumi preview --stack dev
    
    - name: Deploy
      run: pulumi up --yes --stack dev
      env:
        PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
```

## Корисні ресурси

- [Офіційна документація](https://www.pulumi.com/docs/)
- [Приклади проектів](https://github.com/pulumi/examples)
- [Pulumi Registry](https://www.pulumi.com/registry/)
- [Pulumi Blog](https://www.pulumi.com/blog/)

## Підтримка

- [Pulumi Community Slack](https://slack.pulumi.com/)
- [GitHub Issues](https://github.com/pulumi/pulumi/issues)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/pulumi) 