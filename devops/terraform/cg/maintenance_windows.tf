resource "aws_s3_bucket" "log_bucket" {
  bucket = "patchlogs-${replace(var.common_tags["Environment"], " ", "-")}-s3bucket"
}

resource "aws_s3_bucket_public_access_block" "log_bucket_block" {
  bucket                  = aws_s3_bucket.log_bucket.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_ssm_maintenance_window" "linux_maintenance_window" {
  name                       = "${replace(var.common_tags["Project"], " ", "-")}-${replace(var.common_tags["Environment"], " ", "-")}-maintenance-window"
  description                = "Maintenance window for ${replace(var.common_tags["Project"], " ", "-")} in ${replace(var.common_tags["Environment"], " ", "-")} environment"
  duration                   = 1
  cutoff                     = 0
  schedule                   = var.schedule
  schedule_timezone          = "UTC"
  allow_unassociated_targets = false

  tags = merge(var.common_tags, {
    Name = "${replace(var.common_tags["Project"], " ", "-")}-${replace(var.common_tags["Environment"], " ", "-")}-maintenance-window"
  })
}

resource "aws_ssm_maintenance_window_target" "linux_servers" {
  window_id   = aws_ssm_maintenance_window.linux_maintenance_window.id
  name        = "${replace(var.common_tags["Project"], " ", "-")}-${replace(var.common_tags["Environment"], " ", "-")}-targets"
  description = "Target Linux servers in ${replace(var.common_tags["Project"], " ", "-")} for ${replace(var.common_tags["Environment"], " ", "-")} environment"

  resource_type = "RESOURCE_GROUP"

  targets {
    key    = "resource-groups:Name"
    values = ["${replace(var.common_tags["Project"], " ", "-")}-${replace(var.common_tags["Environment"], " ", "-")}-rg"]
  }

  targets {
    key    = "resource-groups:ResourceTypeFilters"
    values = ["AWS::EC2::Instance"]
  }
}

resource "aws_ssm_maintenance_window_task" "linux_maintenance_task" {
  name            = "${replace(var.common_tags["Project"], " ", "-")}-${replace(var.common_tags["Environment"], " ", "-")}-task"
  max_concurrency = 10
  max_errors      = 0
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.linux_maintenance_window.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.linux_servers.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      document_version     = "$DEFAULT"
      timeout_seconds      = 600
      output_s3_bucket     = "patchlogs-${replace(var.common_tags["Environment"], " ", "-")}-s3bucket"
      output_s3_key_prefix = "${replace(var.common_tags["Project"], " ", "-")}-${replace(var.common_tags["Environment"], " ", "-")}"

      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }
}

resource "aws_iam_role" "ssm_maintenance_window_role" {
  name = "${replace(var.common_tags["Project"], " ", "-")}-${var.Environment}-maintenance-window-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ssm.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name        = "${replace(var.common_tags["Project"], " ", "-")}-${var.Environment}-maintenance-window-role"
    Environment = var.Environment
  })
}

resource "aws_iam_policy" "ssm_maintenance_window_policy" {
  name        = "${replace(var.common_tags["Project"], " ", "-")}-${var.Environment}-ssm-maintenance-policy"
  description = "IAM policy for SSM Maintenance Window tasks in ${var.Environment} environment."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:CancelCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:ListCommands",
          "ssm:SendCommand",
          "ssm:GetAutomationExecution",
          "ssm:GetParameters",
          "ssm:StartAutomationExecution",
          "ssm:StopAutomationExecution",
          "ssm:ListTagsForResource",
          "ssm:GetCalendarState"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:UpdateServiceSetting",
          "ssm:GetServiceSetting"
        ],
        "Resource" : [
          "arn:aws:ssm:*:*:servicesetting/ssm/opsitem/*",
          "arn:aws:ssm:*:*:servicesetting/ssm/opsdata/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstances"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "lambda:InvokeFunction",
        "Resource" : [
          "arn:aws:lambda:*:*:function:SSM*",
          "arn:aws:lambda:*:*:function:*:SSM*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "states:DescribeExecution",
          "states:StartExecution"
        ],
        "Resource" : [
          "arn:aws:states:*:*:stateMachine:SSM*",
          "arn:aws:states:*:*:execution:SSM*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "resource-groups:ListGroups",
          "resource-groups:ListGroupResources",
          "resource-groups:GetGroupQuery"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudformation:DescribeStacks",
          "cloudformation:ListStackResources"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "tag:GetResources",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "config:SelectResourceConfig",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "compute-optimizer:GetEC2InstanceRecommendations",
          "compute-optimizer:GetEnrollmentStatus"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "support:DescribeTrustedAdvisorChecks",
          "support:DescribeTrustedAdvisorCheckSummaries",
          "support:DescribeTrustedAdvisorCheckResult",
          "support:DescribeCases"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "config:DescribeComplianceByConfigRule",
          "config:DescribeComplianceByResource",
          "config:DescribeRemediationConfigurations",
          "config:DescribeConfigurationRecorders"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "cloudwatch:DescribeAlarms",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : [
              "ssm.amazonaws.com"
            ]
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : "organizations:DescribeOrganization",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "cloudformation:ListStackSets",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudformation:ListStackInstances",
          "cloudformation:DescribeStackSetOperation",
          "cloudformation:DeleteStackSet"
        ],
        "Resource" : "arn:aws:cloudformation:*:*:stackset/AWS-QuickSetup-SSM*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : "cloudformation:DeleteStackInstances",
        "Resource" : [
          "arn:aws:cloudformation:*:*:stackset/AWS-QuickSetup-SSM*:*",
          "arn:aws:cloudformation:*:*:stackset-target/AWS-QuickSetup-SSM*:*",
          "arn:aws:cloudformation:*:*:type/resource/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "events:PutRule",
          "events:PutTargets"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "events:ManagedBy" : "ssm.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "events:RemoveTargets",
          "events:DeleteRule"
        ],
        "Resource" : [
          "arn:aws:events:*:*:rule/SSMExplorerManagedRule"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "events:DescribeRule",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "securityhub:DescribeHub",
        "Resource" : "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${replace(var.common_tags["Project"], " ", "-")}-${var.Environment}-ssm-maintenance-policy"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_maintenance_window_role_policy" {
  role       = aws_iam_role.ssm_maintenance_window_role.name
  policy_arn = aws_iam_policy.ssm_maintenance_window_policy.arn
}
