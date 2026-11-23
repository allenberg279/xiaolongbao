variable "region" {
  description = "Audit bucket region"
  type        = string
  default     = "cn-hangzhou"
}
variable "name_prefix" {
  description = "Resource naming prefix"
  type        = string
  default     = "lz"
}
variable "audit_bucket_name" {
  description = "Globally unique, private OSS bucket name for audit logs"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.audit_bucket_name))
    error_message = "Supply an OSS bucket name (3-63 chars, lower-case letters, numbers, hyphens)."
  }
}
variable "enable_actiontrail" {
  description = "Do not enable until delivery RAM role and required authorization are reviewed"
  type        = bool
  default     = false
}
variable "actiontrail_oss_write_role_arn" {
  description = "RAM role ARN permitted to write ActionTrail events into the log bucket"
  type        = string
  default     = ""
}
variable "organization_trail" {
  description = "Requires Resource Directory management account and multi-account audit permissions"
  type        = bool
  default     = false
}
