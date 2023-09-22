module "connect_instance" {
  source              = "./modules/connect-instance"
  instance_alias      = local.prefix
  enable_contact_lens = var.enable_contact_lens
}

module "kms_key" {
  source = "terraform-aws-modules/kms/aws"

  description = "Amazon Connect key usage"
  key_usage   = "ENCRYPT_DECRYPT"

  # Policy
  enable_default_policy = true

  # Aliases
  aliases = ["${local.prefix}-key"]
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${local.prefix}-storage"

  # security
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  attach_public_policy    = false
  versioning = {
    enabled = true
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.kms_key.key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  # compliance
  object_lock_enabled = var.bucket_object_lock_enabled
  object_lock_configuration = var.bucket_object_lock_enabled == false ? null : {
    rule = {
      default_retention = {
        mode = "COMPLIANCE"
        days = var.bucket_compliance_days
      }
    }
  }
  # for development only
  force_destroy = var.bucket_force_delete
}

resource "aws_connect_instance_storage_config" "call_recordings" {
  instance_id   = module.connect_instance.id
  resource_type = "CALL_RECORDINGS"

  storage_config {
    s3_config {
      bucket_name   = module.s3_bucket.s3_bucket_id
      bucket_prefix = "CallRecordings"

      encryption_config {
        encryption_type = "KMS"
        key_id          = module.kms_key.key_arn
      }
    }
    storage_type = "S3"
  }
}

module "kinesis_contact_trace_records" {
  source = "./modules/kinesis-stream"

  name        = "${local.prefix}-contact-trace-records"
  kms_key_id  = module.kms_key.key_id
  stream_mode = "ON_DEMAND"
}

resource "aws_connect_instance_storage_config" "contact_trace_records" {
  instance_id   = module.connect_instance.id
  resource_type = "CONTACT_TRACE_RECORDS"

  storage_config {
    kinesis_stream_config {
      stream_arn = module.kinesis_contact_trace_records.arn
    }
    storage_type = "KINESIS_STREAM"
  }
}

module "contact_trace_records_lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${local.prefix}-contact-trace-records"
  description   = "Triggered by Kinesis Stream"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  source_path   = "./src/connect-stream"

  attach_policy_statements = true
  policy_statements = {
    kinesis = {
      effect = "Allow",
      actions = [
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:DescribeStream",
        "kinesis:ListShards",
        "kinesis:ListStreams"
      ],
      resources = [
        module.kinesis_contact_trace_records.arn
      ]
    },
    kms = {
      effect = "Allow",
      actions = [
        "kms:Decrypt"
      ],
      resources = [
        module.kms_key.key_arn
      ]
    }
  }
}

resource "aws_lambda_event_source_mapping" "contact_trace_records" {
  event_source_arn  = module.kinesis_contact_trace_records.arn
  function_name     = module.contact_trace_records_lambda_function.lambda_function_name
  starting_position = "LATEST"
}

resource "aws_lambda_permission" "contact_trace_records" {
  action        = "lambda:InvokeFunction"
  function_name = module.contact_trace_records_lambda_function.lambda_function_name
  principal     = "kinesis.amazonaws.com"
  source_arn    = module.kinesis_contact_trace_records.arn
}

module "kinesis_agent_events" {
  source = "./modules/kinesis-stream"

  name        = "${local.prefix}-agent-events"
  kms_key_id  = module.kms_key.key_id
  stream_mode = "ON_DEMAND"
}

resource "aws_connect_instance_storage_config" "agent_events" {
  instance_id   = module.connect_instance.id
  resource_type = "AGENT_EVENTS"

  storage_config {
    kinesis_stream_config {
      stream_arn = module.kinesis_agent_events.arn
    }
    storage_type = "KINESIS_STREAM"
  }
}

module "agent_events_lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${local.prefix}-agent-events"
  description   = "Triggered by Kinesis Stream"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  source_path   = "./src/connect-stream"

  attach_policy_statements = true
  policy_statements = {
    kinesis = {
      effect = "Allow",
      actions = [
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:DescribeStream",
        "kinesis:ListShards",
        "kinesis:ListStreams"
      ],
      resources = [
        module.kinesis_agent_events.arn
      ]
    },
    kms = {
      effect = "Allow",
      actions = [
        "kms:Decrypt"
      ],
      resources = [
        module.kms_key.key_arn
      ]
    }
  }
}

resource "aws_lambda_event_source_mapping" "agent_events" {
  event_source_arn  = module.kinesis_agent_events.arn
  function_name     = module.agent_events_lambda_function.lambda_function_name
  starting_position = "LATEST"
}

resource "aws_lambda_permission" "agent_events" {
  action        = "lambda:InvokeFunction"
  function_name = module.agent_events_lambda_function.lambda_function_name
  principal     = "kinesis.amazonaws.com"
  source_arn    = module.kinesis_agent_events.arn
}

module "sns_alarm_topic" {
  source = "./modules/sns-topic"

  topic_name             = "${local.prefix}-notification"
  subscription_endpoints = var.subscription_endpoints
}

module "connect_alarms" {
  source = "./modules/connect-alarms"

  project       = local.prefix
  instance_id   = module.connect_instance.id
  sns_topic_arn = module.sns_alarm_topic.arn

  connect_log_group_name = module.connect_instance.log_group_name
  connect_did_numbers    = []
  missed_calls_threshold = 10
  # connect_queues = {
  #   "queue_name" = {
  #     "threshold_max_wait" = "500"
  #     "threshold_capacity" = "10"
  #   }
  # }
  contact_flows_names          = []
  lambda_functions_names       = []
  outbound_contact_flows_names = []
}
