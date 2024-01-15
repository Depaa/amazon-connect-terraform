variable "instance_id" {
  type        = string
  description = "The identifier of the Connect instance."
}

variable "project" {
  description = "Project name."
  type        = string
}

variable "contact_flows_names" {
  description = "Contact flow names list."
  type        = list(string)
  default     = []
}

variable "outbound_contact_flows_names" {
  description = "Outbound contact flow names list."
  type        = list(string)
  default     = []
}

variable "lambda_functions_names" {
  description = "Lambda functions names list."
  type        = list(string)
  default     = []
}

variable "connect_log_group_name" {
  description = "Amazon Connect instance log group name."
  type        = string
  default     = ""
}

/*
* example:
* { "+390000000000" = "500"}
* { "{number}" = {threshold_count}}
*/
variable "connect_numbers" {
  description = "Connect phone numbers list with max allowed number of call."
  type        = map(string)
  default     = {}
}

/*
* example:
* {
*    "queue_name" = {
*      "threshold_max_wait" = "500",
*      "threshold_capacity" = "200"
*    }
*  }
* { 
*   "{queue_name}" = {
*     "threshold_max_wait" = "{threshold_seconds}",
*     "threshold_capacity" = "{threshold_count}"
*   }
* }
*/
variable "connect_queues" {
  description = "Connect Queue list with max allowed waiting time."
  type        = map(map(string))
  default     = {}
}

variable "missed_calls_threshold" {
  description = "Maximum allowed missed calls by Agents."
  type        = number
  default     = 10
}

variable "sns_topic_arn" {
  type        = string
  default     = null
  description = "The ARN of the SNS topic to which the Alarm will alert."
}
