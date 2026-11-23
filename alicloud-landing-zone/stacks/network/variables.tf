variable "region" {
  description = "VPC region"
  type        = string
  default     = "cn-hangzhou"
}

variable "name_prefix" {
  description = "Resource naming prefix"
  type        = string
  default     = "lz"
}

variable "vpc_cidr" {
  description = "Non-overlapping RFC1918 VPC CIDR"
  type        = string
  default     = "10.20.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR."
  }
}

variable "vswitches" {
  description = "Private vSwitches by name; set real zone IDs before deployment."
  type = map(object({
    zone_id    = string
    cidr_block = string
  }))
  default = {}
}
