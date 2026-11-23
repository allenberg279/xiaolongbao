output "vpc_id" {
  description = "VPC ID for future CEN/ACK modules"
  value       = alicloud_vpc.shared.id
}
output "private_vswitch_ids" {
  description = "Private vSwitch IDs keyed by their logical name"
  value       = { for k, v in alicloud_vswitch.private : k => v.id }
}
