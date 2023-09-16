locals {
  prefix = "${var.environment}-${var.company}-${var.project}"

  required_tags = {
    environment = var.environment
    project     = var.project
    company     = var.company
    terraform   = true
  }

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}
