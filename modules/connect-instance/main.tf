resource "aws_connect_instance" "this" {
  instance_alias       = var.instance_alias
  contact_lens_enabled = var.enable_contact_lens

  identity_management_type  = "CONNECT_MANAGED"
  inbound_calls_enabled     = true
  outbound_calls_enabled    = true
  contact_flow_logs_enabled = true
}
