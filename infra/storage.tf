# ============================================================
# 存储 / 凭据模块
# - OBS artifact：工作区产物同步（rclone 指向 OBS 内网 endpoint）
# - OBS audit：承接 CTS 审计日志
# - DEW(csms) secret：存放 broker 连接信息
# ============================================================

resource "huaweicloud_obs_bucket" "artifact" {
  bucket        = "${var.project_name}-artifact"
  acl           = "private"
  storage_class = "STANDARD"
  force_destroy = true
  tags = {
    project = var.project_name
    usage   = "sourcecode-artifact-sync"
  }
}

resource "huaweicloud_obs_bucket" "audit" {
  bucket        = "${var.project_name}-audit"
  acl           = "private"
  storage_class = "STANDARD"
  force_destroy = true
  tags = {
    project = var.project_name
    usage   = "cts-audit-logs"
  }
}

# RabbitMQ 连接凭据（由 DEW 凭据管理托管）
resource "huaweicloud_csms_secret" "broker" {
  name        = "${var.project_name}-broker"
  description = "DMS RabbitMQ 连接信息"
  secret_text = jsonencode({
    host      = huaweicloud_dms_rabbitmq_instance.this.management_connect_address
    amqp_port = huaweicloud_dms_rabbitmq_instance.this.port
    username  = huaweicloud_dms_rabbitmq_instance.this.access_user
    # 密码经 TF_VAR_rabbitmq_password 注入，不落盘；此处仅存结构
  })
}
