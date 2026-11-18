# ============================================================
# 安全 / IAM 模块
# - 委托(agency)：让 ECS 实例获得访问 OBS 的权限
# 说明：Windows ECS 使用密码登录（admin_pass），密钥对不适用，直接删除。
# ============================================================

resource "huaweicloud_identity_agency" "ecs_obs" {
  name                   = "${var.project_name}-ecs-obs"
  delegated_service_name = "op_svc_ecs"
  domain_roles           = ["OBS Operate"]
}
