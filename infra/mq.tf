# ============================================================
# 消息队列模块
# 华为云 DMS RabbitMQ 引擎，单节点（broker_num=1），置于私网子网
# 管理端口 15672 / AMQP 5672；安全组已在 private-sg 内放行同 VPC
# 规格：用 huaweicloud_dms_product 数据源按区域自动匹配（实测手写
#       rabbitmq.s1.small + dms.physical.storage.high 会报 DMS.00400009）
# ============================================================

data "huaweicloud_dms_product" "rabbitmq_single" {
  engine        = "rabbitmq"
  instance_type = "single"
  version       = "3.8.35"
}

resource "huaweicloud_dms_rabbitmq_instance" "this" {
  name               = "${var.project_name}-rabbitmq"
  engine_version     = data.huaweicloud_dms_product.rabbitmq_single.version
  storage_spec_code  = data.huaweicloud_dms_product.rabbitmq_single.storage_spec_code
  product_id         = data.huaweicloud_dms_product.rabbitmq_single.id
  storage_space      = 100 # GB，单机版最小 100GB；product_id 与 storage_space 成对指定
  vpc_id             = huaweicloud_vpc.this.id
  network_id         = huaweicloud_vpc_subnet.private.id
  security_group_id  = huaweicloud_networking_secgroup.private.id
  availability_zones = [var.availability_zone]
  access_user        = "rabbitadmin"
  password           = var.rabbitmq_password

  tags = {
    project = var.project_name
  }
}
