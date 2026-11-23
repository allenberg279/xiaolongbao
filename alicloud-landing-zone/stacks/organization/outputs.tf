output "top_level_folder_ids" {
  value       = { for k, v in alicloud_resource_manager_folder.top : k => v.id }
  description = "Folder IDs for later account factory / policy modules"
}
output "workload_folder_ids" {
  value       = { for k, v in alicloud_resource_manager_folder.workload : k => v.id }
  description = "Workload subfolder IDs"
}
