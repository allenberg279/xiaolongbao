# Run only in the existing Resource Directory management account.
# Does not activate Resource Directory or create Alibaba Cloud accounts.
resource "alicloud_resource_manager_folder" "top" {
  for_each    = var.top_level_folders
  folder_name = "${var.name_prefix}-${each.value}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "alicloud_resource_manager_folder" "workload" {
  for_each         = var.workload_environments
  folder_name      = "${var.name_prefix}-${each.value}"
  parent_folder_id = alicloud_resource_manager_folder.top["Workloads"].id

  lifecycle {
    prevent_destroy = true
  }
}
