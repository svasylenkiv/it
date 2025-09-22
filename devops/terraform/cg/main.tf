# ------------------------------------------------------------
# Find latest Amazon Linux 2 AMI
# ------------------------------------------------------------
data "aws_ami" "latest_amazon_linux_ami" {
  owners      = [var.ami_config["owner"]]
  most_recent = true # Get the latest AMI

  filter {
    name   = "name"
    values = [var.ami_config["name"]] # Amazon Linux 2023
  }
}

# ------------------------------------------------------------
# Create EC2 instance in the private stg subnet
# ------------------------------------------------------------
resource "aws_key_pair" "cg-unified-project-key" {
  key_name   = "${var.project_name}-${var.env}"
  public_key = file("../keys/${var.env}-key.pub")
  tags       = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}" })
}
# ------------------------------------------------------------
# Create EC2 instance in the private subnet
# ------------------------------------------------------------
data "template_file" "user_data" {
 template = base64encode(file("./user_data.sh"))
 vars = {
   newrelic_license_key   = var.newrelic_license_key
   gh_token               = var.gh_token
   env                    = var.env
   aspnetcore_environment = var.aspnetcore_environment
   github_runner_label    = var.github_runner_label
 }
}

resource "aws_instance" "cg-unified-project-instance" {
  ami                    = data.aws_ami.latest_amazon_linux_ami.id
  instance_type          = var.instance_config["instance_type"]
  subnet_id              = var.instance_config["subnet_id"]
  vpc_security_group_ids = [aws_security_group.cg-unified-project-instance-sg.id]
  key_name               = aws_key_pair.cg-unified-project-key.key_name
  iam_instance_profile   = aws_iam_instance_profile.cg-unified-project-instance-profile.name
  user_data              = data.template_file.user_data.rendered

  root_block_device {
    volume_type           = var.instance_config["root_volume_type"]
    volume_size           = var.instance_config["root_volume_size"]
    encrypted             = var.instance_config["encrypted"]
    delete_on_termination = var.instance_config["delete_on_termination"]

    tags = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}-root-volume" })
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}", OS = "${var.OS}" })

    lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}

# ------------------------------------------------------------
# Create security group for the EC2 instance in predifined VPC
# ------------------------------------------------------------
resource "aws_security_group" "cg-unified-project-instance-sg" {
  name   = "${var.project_name}-${var.env}-instance-security-group"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.caseglide_instance_security_group_config
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      description     = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}" })

}

# ------------------------------------------------------------
# Create new CaseGlide webapp role for instance
# ------------------------------------------------------------
resource "aws_iam_role" "caseglide-webapp-role-unified-project" {
  name = "caseglide-webapp-role-unified-project-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "cg-unified-project-instance-profile" {
  # Use prefix becouse instance profile name must be unique
  name_prefix = "${var.project_name}-${var.env}-"
  role        = aws_iam_role.caseglide-webapp-role-unified-project.name
}

# ------------------------------------------------------------
# CaseGlide AWS magaged policy for webapp role
# ------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "caseglide-webapp-role-unified-project" {
  for_each = var.managed_policies

  policy_arn = each.value
  role       = aws_iam_role.caseglide-webapp-role-unified-project.name
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE A TARGET GROUP FOR LB
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "target_group_webapp" {
  name        = "${var.project_name}-${var.env}"
  port        = var.target_group_webapp_config["port"]
  protocol    = var.target_group_webapp_config["protocol"]
  vpc_id      = var.vpc_id
  target_type = var.target_group_webapp_config["target_type"]
}

resource "aws_lb_target_group_attachment" "target_group_webapp_attachment" {
  target_group_arn = aws_lb_target_group.target_group_webapp.arn
  target_id        = aws_instance.cg-unified-project-instance.id
  port             = 80
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP THAT CONTROLS WHAT TRAFFIC AN GO IN AND OUT OF THE ELB
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "caseglide_lb_security_group" {
  name   = "${var.project_name}-${var.env}-lb-security-group"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.caseglide_lb_security_group_config
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      description     = ingress.value.description
    }
  }

  # Allow all outbound
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------
# Create AWS load balancer
# ------------------------------------------------------------
resource "aws_lb" "cg-unified-project_lb" {
  name                       = "${var.project_name}-${var.env}"
  internal                   = var.caseglide_webapp_lb_config["internal"]
  load_balancer_type         = var.caseglide_webapp_lb_config["load_balancer_type"]
  security_groups            = ["${aws_security_group.caseglide_lb_security_group.id}"]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.caseglide_webapp_lb_config["enable_deletion_protection"]
  tags                       = merge(var.common_tags, { Name = "${var.project_name}-${var.common_tags["Environment"]}" })
}

resource "aws_lb_listener" "front_end_80" {
  load_balancer_arn = aws_lb.cg-unified-project_lb.arn
  port              = var.front_end_80_config["port"]
  protocol          = var.front_end_80_config["protocol"]

  default_action {
    type = var.front_end_80_config["type"]

    redirect {
      port        = var.front_end_80_config["redirect_port"]
      protocol    = var.front_end_80_config["redirect_protocol"]
      status_code = var.front_end_80_config["status_code"]
    }
  }
}

resource "aws_lb_listener" "front_end_443" {
  load_balancer_arn = aws_lb.cg-unified-project_lb.arn
  port              = var.front_end_443_config["port"]
  protocol          = var.front_end_443_config["protocol"]
  ssl_policy        = var.front_end_443_config["ssl_policy"]
  certificate_arn   = var.front_end_443_config["caseglide_certificate"]

  default_action {
    type             = var.front_end_443_config["type"]
    target_group_arn = aws_lb_target_group.target_group_webapp.arn
  }
}
# ------------------------------------------------------------
# Create CNAME in hosted zone
# ------------------------------------------------------------
# resource "aws_route53_record" "cg-unified-project-cname" {
#   zone_id = var.route53_cname_config["zone_id"]
#   name    = var.route53_cname_config["name"]
#   type    = var.route53_cname_config["type"]
#   ttl     = var.route53_cname_config["ttl"]
#   records = ["${aws_lb.cg-unified-project_lb.dns_name}"]
# }
