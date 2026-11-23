terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.294.0"
    }
  }
  backend "oss" {}
}

provider "alicloud" {
  region = var.region
}
