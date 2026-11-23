output "audit_bucket_name" {
  description = "Audit log bucket for later account-level and org-level log sinks"
  value       = alicloud_oss_bucket.audit.bucket
}
output "actiontrail_trail_ids" {
  description = "Optional ActionTrail trail IDs; empty when disabled"
  value       = alicloud_actiontrail_trail.audit[*].id
}
