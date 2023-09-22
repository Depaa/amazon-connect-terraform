/* Service Limit Metrics
* 
* CallsBreachingConcurrencyQuota
* ThrottledCalls
* ConcurrentCallsPercentage
*
*/

resource "aws_cloudwatch_metric_alarm" "calls_breaching_concurrency_quota" {
  alarm_name          = "${var.project}-connect-concurrent-calls-breaching-quotas"
  alarm_description   = "Alarm for Connect Calls Breach Concurrency Quota"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CallsBreachingConcurrencyQuota"
  namespace           = "AWS/Connect"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    InstanceId  = var.instance_id
    MetricGroup = "VoiceCalls"
  }
  evaluation_periods = 1
  threshold          = 1
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "throttled_calls" {
  alarm_name          = "${var.project}-connect-throttled-calls"
  alarm_description   = "Alarm for Connect Throttles Calls"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ThrottledCalls"
  namespace           = "AWS/Connect"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    InstanceId  = var.instance_id
    MetricGroup = "VoiceCalls"
  }
  evaluation_periods = 1
  threshold          = 1
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "concurrent_calls_percentage" {
  alarm_name          = "${var.project}-connect-concurrent-calls-percentage"
  alarm_description   = "Alarm for Connect Concurrent Calls Percentage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ConcurrentCallsPercentage"
  namespace           = "AWS/Connect"
  statistic           = "Maximum"
  unit                = "Percent"
  dimensions = {
    InstanceId  = var.instance_id
    MetricGroup = "VoiceCalls"
  }
  evaluation_periods = 1
  threshold          = 80
  period             = 300

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

/* Instance and Flow metrics
* 
* ToInstancePacketLossRate
* CallRecordingUploadError
* ContactFlowErrors
* ContactFlowFatalErrors
* CallBackNotDialableNumber
* MisconfiguredPhoneNumbers
* Lambda Execution Duration
* Lambda Execution Errors
* Custom: DIDCalls
*
*/

resource "aws_cloudwatch_metric_alarm" "to_instance_packet_loss_rate" {
  alarm_name          = "${var.project}-connect-to-instance-packet-loss-rate"
  alarm_description   = "Alarm for Connect Network Packet Loss Rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ToInstancePacketLossRate"
  namespace           = "AWS/Connect"
  statistic           = "Average"
  unit                = "Percent"
  dimensions = {
    "Instance ID"        = var.instance_id
    Participant          = "Agent"
    "Type of Connection" = "WebRTC"
    "Stream Type"        = "Voice"
  }
  evaluation_periods = 1
  threshold          = 0.05
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "call_recording_upload_error" {
  alarm_name          = "${var.project}-connect-call-recording-upload-error"
  alarm_description   = "Alarm for Call Recording Upload Error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CallRecordingUploadError"
  namespace           = "AWS/Connect"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    InstanceId  = var.instance_id
    MetricGroup = "CallRecordings"
  }
  evaluation_periods = 1
  threshold          = 1
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "contact_flow_errors" {
  count               = length(var.contact_flows_names)
  alarm_name          = "${var.project}-connect-contact-flow-errors-${var.contact_flows_names[count.index]}"
  alarm_description   = "Alarm for Contact Flow Errors ${var.contact_flows_names[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ContactFlowErrors"
  namespace           = "AWS/Connect"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    InstanceId      = var.instance_id
    MetricGroup     = "ContactFlow"
    ContactFlowName = var.contact_flows_names[count.index]
  }
  evaluation_periods = 1
  threshold          = 1
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "contact_flow_fatal_errors" {
  count               = length(var.contact_flows_names)
  alarm_name          = "${var.project}-connect-contact-flow-fatal-errors-${var.contact_flows_names[count.index]}"
  alarm_description   = "Alarm for Contact Flow Fatal Errors ${var.contact_flows_names[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "ContactFlowFatalErrors"
  namespace           = "AWS/Connect"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    InstanceId      = var.instance_id
    MetricGroup     = "ContactFlow"
    ContactFlowName = var.contact_flows_names[count.index]
  }
  evaluation_periods = 1
  threshold          = 1
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "call_back_not_dialable" {
  count               = length(var.outbound_contact_flows_names)
  alarm_name          = "${var.project}-connect-call-back-not-dialable-${var.outbound_contact_flows_names[count.index]}"
  alarm_description   = "Alarm for Call Back Not Dialable Number ${var.outbound_contact_flows_names[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CallBackNotDialableNumber"
  namespace           = "AWS/Connect"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    InstanceId      = var.instance_id
    MetricGroup     = "ContactFlow"
    ContactFlowName = var.outbound_contact_flows_names[count.index]
  }
  evaluation_periods = 1
  threshold          = 1
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "misconfigured_phone_numbers" {
  alarm_name          = "${var.project}-connect-misconfigured-phone-numbers"
  alarm_description   = "Alarm for Misconfigured Phone Numbers"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "MisconfiguredPhoneNumbers"
  namespace           = "AWS/Connect"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    InstanceId  = var.instance_id
    MetricGroup = "VoiceCalls"
  }
  evaluation_periods = 1
  threshold          = 1
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "lambda_execution_duration" {
  count               = length(var.lambda_functions_names)
  alarm_name          = "${var.project}-lambda-execution-duration-${var.lambda_functions_names[count.index]}"
  alarm_description   = "Alarm for Lambda Execution Duration ${var.lambda_functions_names[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  statistic           = "Maximum"
  unit                = "Milliseconds"
  dimensions = {
    FunctionName = var.lambda_functions_names[count.index]
  }
  evaluation_periods = 2
  threshold          = 6000
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "lambda_execution_errors" {
  count               = length(var.lambda_functions_names)
  alarm_name          = "${var.project}-lambda-execution-errors-${var.lambda_functions_names[count.index]}"
  alarm_description   = "Alarm for Lambda Execution Errors ${var.lambda_functions_names[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    FunctionName = var.lambda_functions_names[count.index]
  }
  evaluation_periods = 1
  threshold          = 1
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "custom_did_number" {
  name           = "${var.project}-connect-DID"
  pattern        = "{ $.Parameters.Value != \"\" && $.Parameters.Key = \"SystemEndpointAddress\" }"
  log_group_name = var.connect_log_group_name

  metric_transformation {
    name          = "DID"
    namespace     = var.project
    value         = "1"
    unit          = "Count"
    default_value = "0"
    dimensions = {
      DID = "$.Parameters.Value"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "custom_did_number" {
  for_each            = var.connect_did_numbers
  alarm_name          = "${var.project}-connect-DID-alarm-${each.key}"
  alarm_description   = "Alarm for DID ${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "DID"
  namespace           = var.project
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    DID = each.key
  }
  evaluation_periods = 1
  threshold          = 1
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}


/* Business Metrics
* 
* LongestQueueWaitTime
* QueueSize
* QueueCapacityExceededError
* MissedCalls
*
*/

resource "aws_cloudwatch_metric_alarm" "longest_queue_wait_time" {
  for_each            = var.connect_queues
  alarm_name          = "${var.project}-queue-wait-time-${each.key}"
  alarm_description   = "Alarm for Longest Queue Wait Time ${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "LongestQueueWaitTime"
  namespace           = "AWS/Connect"
  statistic           = "Maximum"
  unit                = "Seconds"
  dimensions = {
    InstanceId  = var.instance_id
    MetricGroup = "Queue",
    QueueName   = each.key
  }
  evaluation_periods = 1
  threshold          = each.value["threshold_max_wait"]
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "queue_size" {
  for_each            = var.connect_queues
  alarm_name          = "${var.project}-queue-size-${each.key}"
  alarm_description   = "Alarm for Queue Size ${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "QueueSize"
  namespace           = "AWS/Connect"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    InstanceId  = var.instance_id
    MetricGroup = "Queue",
    QueueName   = each.key
  }
  evaluation_periods = 1
  threshold          = each.value["threshold_capacity"]
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "queue_capacity_exceeded_error" {
  for_each            = var.connect_queues
  alarm_name          = "${var.project}-queue-capacity-exceeded-error-${each.key}"
  alarm_description   = "Alarm for Queue Capacity Exceeded Error ${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "QueueCapacityExceededError"
  namespace           = "AWS/Connect"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    InstanceId  = var.instance_id
    MetricGroup = "Queue",
    QueueName   = each.key
  }
  evaluation_periods = 1
  threshold          = 1
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "missed_calls" {
  alarm_name          = "${var.project}-connect-missed-calls"
  alarm_description   = "Alarm for Missed Calls"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "MissedCalls"
  namespace           = "AWS/Connect"
  statistic           = "Sum"
  unit                = "Count"
  dimensions = {
    InstanceId  = var.instance_id
    MetricGroup = "VoiceCalls"
  }
  evaluation_periods = 1
  threshold          = var.missed_calls_threshold
  period             = 60

  alarm_actions      = var.sns_topic_arn != null ? [var.sns_topic_arn] : null
  treat_missing_data = "notBreaching"
}
