# metadata
environment = "dev"
company     = "blog"
project     = "connect"
region      = "eu-central-1"

tags = {
  "terraform" : true
}

enable_contact_lens        = true
bucket_force_delete        = true
bucket_object_lock_enabled = false
bucket_compliance_days     = 0
subscription_endpoints     = []

/*
 * check out ./modules/connect-alarms
 */
missed_calls_threshold = 1
connect_numbers = {
  "+390000000000" = "1"
}
connect_queues = {
  "BasicQueue" = {
    "threshold_max_wait" = "60" # 1 minute
    "threshold_capacity" = "1"
  }
}
contact_flows_names = [
  "Sample recording behavior"
]
outbound_contact_flows_names = [
  "Default outbound"
]
