variable "environment" {
  type = string
}
variable "company" {
  type = string
}
variable "project" {
  type = string
}
variable "region" {
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_contact_lens" {
  type        = bool
  description = "Boolean to enable contact lens"
  default     = true
}

variable "bucket_force_delete" {
  description = "Force bucket deletion."
  type        = bool
  default     = true
}

variable "bucket_object_lock_enabled" {
  description = "Object lock enable for s3 bucket."
  type        = bool
  default     = false
}

variable "bucket_compliance_days" {
  description = "S3 retention days for s3 bucket."
  type        = number
  default     = 365 # 1 year
}