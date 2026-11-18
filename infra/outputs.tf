# ============================================================
# 输出
# ============================================================

output "vpc_id" {
  value = huaweicloud_vpc.this.id
}

output "workbench_eip" {
  description = "Workbench 公网 IP（RDP 入口，仅运维 IP 可访问 3389）"
  value       = huaweicloud_vpc_eip.workbench.address
}

output "workbench_rdp_hint" {
  description = "RDP 连接提示"
  value       = "mstsc /v:${huaweicloud_vpc_eip.workbench.address}:3389 （用户=Administrator，密码=TF_VAR_windows_admin_password）"
}

output "rabbitmq_management" {
  description = "RabbitMQ 管理控制台地址"
  value       = huaweicloud_dms_rabbitmq_instance.this.management_connect_address
}

output "codearts_project_id" {
  value = var.codearts_enabled ? huaweicloud_codearts_project.this[0].id : null
}
