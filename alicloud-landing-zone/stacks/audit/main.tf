# Basic encrypted, non-public audit storage.
resource "alicloud_oss_bucket" "audit" {
  bucket        = var.audit_bucket_name
  acl           = "private"
  storage_class = "Standard"
  force_destroy = false

  # Standalone resources below own these configurations.
  lifecycle {
    ignore_changes  = [versioning, server_side_encryption_rule]
    prevent_destroy = true
  }
}

resource "alicloud_oss_bucket_public_access_block" "audit" {
  bucket              = alicloud_oss_bucket.audit.bucket
  block_public_access = true
}

resource "alicloud_oss_bucket_versioning" "audit" {
  bucket = alicloud_oss_bucket.audit.bucket
  status = "Enabled"
}

resource "alicloud_oss_bucket_server_side_encryption" "audit" {
  bucket        = alicloud_oss_bucket.audit.bucket
  sse_algorithm = "AES256"
}

# Optional: ActionTrail management events -> OSS (requires valid service role/permissions).
resource "alicloud_actiontrail_trail" "audit" {
  count                 = var.enable_actiontrail ? 1 : 0
  trail_name            = "${var.name_prefix}-audit-trail"
  event_rw              = "All"
  is_organization_trail = var.organization_trail
  oss_bucket_name       = alicloud_oss_bucket.audit.bucket
  oss_write_role_arn    = var.actiontrail_oss_write_role_arn
  status                = "Enable"

  depends_on = [
    alicloud_oss_bucket_public_access_block.audit,
    alicloud_oss_bucket_versioning.audit,
    alicloud_oss_bucket_server_side_encryption.audit
  ]
}
