# ============================================================
# 网络模块：VPC / 子网 / EIP / 安全组
# 注意：华为云 VPC 路由表配额=1（每子网仅 1 张路由表）；
#       子网 id 用 .id，不要误用 ipv4_subnet_id
# 决策：不部署公网 NAT —— Workbench 经 EIP 直接出网，
#       Workers 为纯内网实例（无出网需求）。
# ============================================================

resource "huaweicloud_vpc" "this" {
  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "private" {
  name       = "${var.project_name}-private"
  cidr       = var.private_subnet_cidr
  gateway_ip = cidrhost(var.private_subnet_cidr, 1)
  vpc_id     = huaweicloud_vpc.this.id
}

# Workbench 公网 EIP（RDP 入口，必须锁运维来源 IP）
resource "huaweicloud_vpc_eip" "workbench" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name       = "${var.project_name}-wb-bw"
    size       = 5
    share_type = "PER"
  }
}

# ---------------- 安全组 ----------------
resource "huaweicloud_networking_secgroup" "workbench" {
  name = "${var.project_name}-workbench-sg"
}

resource "huaweicloud_networking_secgroup" "private" {
  name = "${var.project_name}-private-sg"
}

# Workbench：入站仅放开运维 IP 的 3389(RDP)/22(SSH)
resource "huaweicloud_networking_secgroup_rule" "workbench_rdp" {
  for_each          = toset(var.admin_source_cidr)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3389
  port_range_max    = 3389
  remote_ip_prefix  = each.value
  security_group_id = huaweicloud_networking_secgroup.workbench.id
}

resource "huaweicloud_networking_secgroup_rule" "workbench_ssh" {
  for_each          = toset(var.admin_source_cidr)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = each.value
  security_group_id = huaweicloud_networking_secgroup.workbench.id
}

resource "huaweicloud_networking_secgroup_rule" "workbench_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.workbench.id
  remote_ip_prefix  = "0.0.0.0/0"
}

# 私网安全组：仅允许来自 VPC 内部的常用端口（RDP/SSH/RabbitMQ）
resource "huaweicloud_networking_secgroup_rule" "private_ingress_vpc" {
  for_each          = toset(["22", "3389", "5672", "15672"])
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = tonumber(each.value)
  port_range_max    = tonumber(each.value)
  remote_ip_prefix  = var.vpc_cidr
  security_group_id = huaweicloud_networking_secgroup.private.id
}

resource "huaweicloud_networking_secgroup_rule" "private_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.private.id
  remote_ip_prefix  = "0.0.0.0/0"
}
