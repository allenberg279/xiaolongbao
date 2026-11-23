variable "region" {
  description = "Alibaba Cloud region for provider operations"
  type        = string
  default     = "cn-hangzhou"
}

variable "name_prefix" {
  description = "Folder name prefix; avoid conflicts in existing Resource Directory"
  type        = string
  default     = "lz"
  validation {
    condition     = length(var.name_prefix) >= 2 && length(var.name_prefix) <= 24
    error_message = "name_prefix must be 2-24 characters."
  }
}

variable "top_level_folders" {
  description = "Resource Directory folders; existing Resource Directory is a prerequisite"
  type        = set(string)
  default     = ["Security", "SharedServices", "Workloads", "Sandbox"]
}

variable "workload_environments" {
  description = "Subfolders under Workloads; Workloads must be present in top_level_folders"
  type        = set(string)
  default     = ["dev", "test", "prod"]
}
