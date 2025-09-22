resource "aws_sqs_queue" "parse_body_email_dl" {
  name                              = "${var.env}-email-processing-q-inbound-parse-body-email-dl"
  fifo_queue                        = false
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 1209600
  receive_wait_time_seconds         = 0
  visibility_timeout_seconds        = 30
  content_based_deduplication       = false
  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = var.kms_key_id

  tags = {
    Environment = var.env
  }

  tags_all = {
    Environment = var.env
  }
}

resource "aws_sqs_queue" "parse_body_email" {
  name                              = "${var.env}-email-processing-q-inbound-parse-body-email"
  fifo_queue                        = false
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  visibility_timeout_seconds        = 180
  content_based_deduplication       = false
  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = var.kms_key_id

  redrive_policy = jsonencode({
    deadLetterTargetArn = var.dlq_arn
    maxReceiveCount     = 2
  })

  depends_on = [
    aws_sqs_queue.parse_body_email_dl
  ]

  tags = {
    Environment = var.env
  }

  tags_all = {
    Environment = var.env
  }
}

resource "aws_sqs_queue" "parse_email_dl" {
  name                              = "${var.env}-email-processing-q-inbound-parse-email-dl"
  fifo_queue                        = false
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 1209600
  receive_wait_time_seconds         = 0
  visibility_timeout_seconds        = 30
  content_based_deduplication       = false
  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = var.kms_key_id

  tags = {
    Environment = var.env
  }

  tags_all = {
    Environment = var.env
  }
}

resource "aws_sqs_queue" "parse_email" {
  name                              = "${var.env}-email-processing-q-inbound-parse-email"
  fifo_queue                        = false
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  visibility_timeout_seconds        = 180
  content_based_deduplication       = false
  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = var.kms_key_id

  redrive_policy = jsonencode({
    deadLetterTargetArn = var.dlq_arn
    maxReceiveCount     = 2
  })

  depends_on = [
    aws_sqs_queue.parse_email_dl
  ]

  tags = {
    Environment = var.env
  }

  tags_all = {
    Environment = var.env
  }
}

resource "aws_sqs_queue" "proc_email_dl" {
  name                              = "${var.env}-email-processing-q-inbound-proc-email-dl"
  fifo_queue                        = false
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 1209600
  receive_wait_time_seconds         = 0
  visibility_timeout_seconds        = 30
  content_based_deduplication       = false
  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = var.kms_key_id

  tags = {
    Environment = var.env
  }

  tags_all = {
    Environment = var.env
  }
}

resource "aws_sqs_queue" "proc_email" {
  name                              = "${var.env}-email-processing-q-inbound-proc-email"
  fifo_queue                        = false
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  visibility_timeout_seconds        = 180
  content_based_deduplication       = false
  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = var.kms_key_id

  redrive_policy = jsonencode({
    deadLetterTargetArn = var.dlq_arn
    maxReceiveCount     = 2
  })

  depends_on = [
    aws_sqs_queue.proc_email_dl
  ]

  tags = {
    Environment = var.env
  }

  tags_all = {
    Environment = var.env
  }
}

resource "aws_sqs_queue" "validate_email_dl" {
  name                              = "${var.env}-email-processing-q-inbound-validate-email-dl"
  fifo_queue                        = false
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 1209600
  receive_wait_time_seconds         = 0
  visibility_timeout_seconds        = 30
  content_based_deduplication       = false
  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = var.kms_key_id

  tags = {
    Environment = var.env
  }

  tags_all = {
    Environment = var.env
  }
}

resource "aws_sqs_queue" "validate_email" {
  name                              = "${var.env}-email-processing-q-inbound-validate-email"
  fifo_queue                        = false
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  visibility_timeout_seconds        = 180
  content_based_deduplication       = false
  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = var.kms_key_id

  redrive_policy = jsonencode({
    deadLetterTargetArn = var.dlq_arn
    maxReceiveCount     = 2
  })

  depends_on = [
    aws_sqs_queue.validate_email_dl
  ]

  tags = {
    Environment = var.env
  }

  tags_all = {
    Environment = var.env
  }
}

resource "aws_sqs_queue" "outbound_email_dl" {
  name                              = "${var.env}-email-processing-q-outbound-email-dl"
  fifo_queue                        = false
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 1209600
  receive_wait_time_seconds         = 0
  visibility_timeout_seconds        = 30
  content_based_deduplication       = false
  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = var.kms_key_id

  tags = {
    Environment = var.env
  }

  tags_all = {
    Environment = var.env
  }
}

resource "aws_sqs_queue" "outbound_email" {
  name                              = "${var.env}-email-processing-q-outbound-email"
  fifo_queue                        = false
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  visibility_timeout_seconds        = 180
  content_based_deduplication       = false
  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = var.kms_key_id

  redrive_policy = jsonencode({
    deadLetterTargetArn = var.dlq_arn
    maxReceiveCount     = 2
  })

  depends_on = [
    aws_sqs_queue.outbound_email_dl
  ]

  tags = {
    Environment = var.env
  }

  tags_all = {
    Environment = var.env
  }
}