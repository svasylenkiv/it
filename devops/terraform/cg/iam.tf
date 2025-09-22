# --------------------------------------------
# Primary IAM role for the Lambda function
# --------------------------------------------
resource "aws_iam_role" "email_processing" {
  name = "${var.env}-email-processing-r-email-processing"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# --------------------------------------------
# Access policy to SQS for Lambda
# --------------------------------------------
resource "aws_iam_role_policy" "email_processing_sqs_policy" {
  name = "${var.env}-email-processing-sqs-policy"
  role = aws_iam_role.email_processing.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = "arn:aws:sqs:${var.region}:${var.account_id}:${var.env}-email-processing-q-*"
      }
    ]
  })
}

# --------------------------------------------
# Policy to allow lambda:ListTags
# --------------------------------------------
resource "aws_iam_role_policy" "lambda_list_tags" {
  name = "${var.env}-email-list-tag-policy"
  role = aws_iam_role.email_processing.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "VisualEditor0",
        Effect   = "Allow",
        Action   = "lambda:ListTags",
        Resource = "*"
      }
    ]
  })
}

# --------------------------------------------
# Policy for accessing parameters in SSM Parameter Store
# --------------------------------------------
resource "aws_iam_role_policy" "ssm_access" {
  name = "${var.env}-email-processing-ssm-policy"
  role = aws_iam_role.email_processing.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "ssm:GetParametersByPath",          
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Resource = [
          "arn:aws:ssm:*:*:parameter/repos/email-processing*",
          "arn:aws:ssm:*:*:parameter/${var.env}/terraform/rds/caseglideawsdba*",
          "arn:aws:ssm:*:*:parameter/${var.env}/rds/caseglide-db-${var.env}*",
          "arn:aws:ssm:*:*:parameter/${var.env}/email-processing*",
          "arn:aws:ssm:*:*:parameter/${var.env}/caseglide/webapp/dsc/rds*",
          "arn:aws:ssm:*:*:parameter/${var.env}/shared/caseglide-endpoints/primary"
        ]
      }
    ]
  })
}

# --------------------------------------------
# Access policy for writing logs to CloudWatch Logs
# --------------------------------------------
resource "aws_iam_role_policy" "cloudwatch_logs_access" {
  name = "${var.env}-email-processing-logs-policy"
  role = aws_iam_role.email_processing.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/lambda/${var.env}-email-processing-*",
        ]
      }
    ]
  })
}

# --------------------------------------------
# Attaching a managed policy for VPC access from Lambda
# --------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.email_processing.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# --------------------------------------------
# Access policy for objects in S3 buckets
# --------------------------------------------
resource "aws_iam_role_policy" "s3_access" {
  name = "${var.env}-email-processing-s3-policy"
  role = aws_iam_role.email_processing.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "VisualEditor1",
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      Resource = [
        "arn:aws:s3:::caseglide-document-repository",
        "arn:aws:s3:::cg-repos-email-processing",
        "arn:aws:s3:::caseglide-document-repository/*",
        "arn:aws:s3:::cg-repos-email-processing/*"
      ]
    }]
  })
}
