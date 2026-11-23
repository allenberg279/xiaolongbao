# Private network baseline only. No NAT, EIP, public IP, route to Internet, or cluster.
resource "alicloud_vpc" "shared" {
  vpc_name   = "${var.name_prefix}-shared-vpc"
  cidr_block = var.vpc_cidr
  tags = {
    "managed-by" = "terraform"
    "layer"      = "landing-zone"
  }
}

resource "alicloud_vswitch" "private" {
  for_each   = var.vswitches
  vswitch_name = "${var.name_prefix}-${each.key}"
  vpc_id     = alicloud_vpc.shared.id
  zone_id    = each.value.zone_id
  cidr_block = each.value.cidr_block
  tags = {
    "managed-by" = "terraform"
    "tier"       = "private"
  }
}
