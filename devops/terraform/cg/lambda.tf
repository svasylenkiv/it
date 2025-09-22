resource "aws_lambda_function" "email_processing" {
  function_name    = "${var.env}-email-processing-fn-in-parse-body"
  role             = aws_iam_role.email_processing.arn
  handler          = "inbound_parse_body.lambda_handler"
  runtime          = "python3.9"
  memory_size      = 256
  timeout          = 120
  publish          = true
  filename         = "../functions/email-processing-fn-in-parse-body.zip"
  source_code_hash = filebase64sha256("../functions/email-processing-fn-in-parse-body.zip")

  vpc_config {
    subnet_ids                  = var.lambda_subnet_ids
    security_group_ids          = var.lambda_security_group_ids
    ipv6_allowed_for_dual_stack = false
  }

  environment {
    variables = {
      CASEGLIDE_ENVIRONMENT       = var.env
      CASEGLIDE_LOGGING_LEVEL     = "Debug"
      LAMBDA_NET_SERIALIZER_DEBUG = "true"
    }
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_lambda_event_source_mapping" "email_processing_sqs_trigger" {
  event_source_arn        = "arn:aws:sqs:${var.region}:${var.account_id}:${var.env}-email-processing-q-inbound-parse-body-email"
  function_name           = aws_lambda_function.email_processing.function_name
  enabled                 = true
  batch_size              = 10
  function_response_types = ["ReportBatchItemFailures"]

  depends_on = [aws_iam_role_policy.email_processing_sqs_policy]
}

resource "aws_lambda_function" "auth_lambda" {
  function_name    = "${var.env}-email-processing-fn-in-auth"
  role             = aws_iam_role.email_processing.arn
  handler          = "index.handler"
  runtime          = "dotnet8"
  architectures    = ["x86_64"]
  memory_size      = 256
  timeout          = 30
  publish          = true
  filename         = "../functions/email-processing-fn-in-auth.zip"
  source_code_hash = filebase64sha256("../functions/email-processing-fn-in-auth.zip")

  environment {
    variables = {
      CASEGLIDE_ENVIRONMENT       = var.env
      CASEGLIDE_LOGGING_LEVEL     = "Debug"
      LAMBDA_NET_SERIALIZER_DEBUG = "true"
    }
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_lambda_function" "ingest_lambda" {
  function_name    = "${var.env}-email-processing-fn-in-ingest"
  role             = aws_iam_role.email_processing.arn
  handler          = "index.handler"
  runtime          = "dotnet8"
  architectures    = ["x86_64"]
  memory_size      = 256
  timeout          = 30
  publish          = true
  filename         = "../functions/email-processing-fn-in-ingest.zip"
  source_code_hash = filebase64sha256("../functions/email-processing-fn-in-ingest.zip")

  environment {
    variables = {
      CASEGLIDE_ENVIRONMENT       = var.env
      CASEGLIDE_LOGGING_LEVEL     = "Debug"
      LAMBDA_NET_SERIALIZER_DEBUG = "true"
    }
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_lambda_function" "parse_lambda" {
  function_name    = "${var.env}-email-processing-fn-in-parse"
  role             = aws_iam_role.email_processing.arn
  handler          = "index.handler"
  runtime          = "dotnet8"
  architectures    = ["x86_64"]
  memory_size      = 256
  timeout          = 30
  publish          = true
  filename         = "../functions/email-processing-fn-in-parse.zip"
  source_code_hash = filebase64sha256("../functions/email-processing-fn-in-parse.zip")

  environment {
    variables = {
      CASEGLIDE_ENVIRONMENT       = var.env
      CASEGLIDE_LOGGING_LEVEL     = "Debug"
      LAMBDA_NET_SERIALIZER_DEBUG = "true"
    }
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_lambda_function" "proc_lambda" {
  function_name    = "${var.env}-email-processing-fn-in-proc"
  role             = aws_iam_role.email_processing.arn
  handler          = "index.handler"
  runtime          = "dotnet8"
  architectures    = ["x86_64"]
  memory_size      = 256
  timeout          = 30
  publish          = true
  filename         = "../functions/email-processing-fn-in-proc.zip"
  source_code_hash = filebase64sha256("../functions/email-processing-fn-in-proc.zip")

  environment {
    variables = {
      CASEGLIDE_ENVIRONMENT       = var.env
      CASEGLIDE_LOGGING_LEVEL     = "Debug"
      LAMBDA_NET_SERIALIZER_DEBUG = "true"
    }
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_lambda_function" "validate_lambda" {
  function_name    = "${var.env}-email-processing-fn-in-validate"
  role             = aws_iam_role.email_processing.arn
  handler          = "index.handler"
  runtime          = "dotnet8"
  architectures    = ["x86_64"]
  memory_size      = 256
  timeout          = 30
  publish          = true
  filename         = "../functions/email-processing-fn-in-validate.zip"
  source_code_hash = filebase64sha256("../functions/email-processing-fn-in-validate.zip")

  environment {
    variables = {
      CASEGLIDE_ENVIRONMENT       = var.env
      CASEGLIDE_LOGGING_LEVEL     = "Debug"
      LAMBDA_NET_SERIALIZER_DEBUG = "true"
    }
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_lambda_function" "out-proc_lambda" {
  function_name    = "${var.env}-email-processing-fn-out-proc"
  role             = aws_iam_role.email_processing.arn
  handler          = "index.handler"
  runtime          = "dotnet8"
  architectures    = ["x86_64"]
  memory_size      = 256
  timeout          = 30
  publish          = true
  filename         = "../functions/email-processing-fn-out-proc.zip"
  source_code_hash = filebase64sha256("../functions/email-processing-fn-out-proc.zip")

  environment {
    variables = {
      CASEGLIDE_ENVIRONMENT       = var.env
      CASEGLIDE_LOGGING_LEVEL     = "Debug"
      LAMBDA_NET_SERIALIZER_DEBUG = "true"
    }
  }

  tags = {
    Environment = var.env
  }
}