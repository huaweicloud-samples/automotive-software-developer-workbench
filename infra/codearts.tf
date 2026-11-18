# ============================================================
# 软件工厂模块（CodeArts）
# 说明：此处仅交付流水线骨架，具体构建步骤(steps)需接入实际代码仓后补全。
# 注意：CodeArts 需账号先在控制台开通服务（实测报 PM.02100546「企业租户服务关闭」），
#       开通后置 codearts_enabled=true 再 apply。
# ============================================================

resource "huaweicloud_codearts_project" "this" {
  count = var.codearts_enabled ? 1 : 0
  name  = "${var.project_name}-factory"
  type  = "scrum"
}

resource "huaweicloud_codearts_build_task" "factory" {
  count      = var.codearts_enabled ? 1 : 0
  name       = "${var.project_name}-build"
  project_id = huaweicloud_codearts_project.this[0].id
  arch       = "x86_64"
  flavor     = "build.general1.small"
  host_type  = "linux"

  # 占位构建步骤：接入实际代码仓与 ETAS 工具链后替换。
  # steps 由 CodeArts Build 步骤模块组成：module_id 为步骤模块 ID（如 shell），
  # properties 为步骤参数 map（shell 步骤的 command 为执行命令）。
  steps {
    name      = "placeholder"
    module_id = "shell"
    properties = {
      command = "echo 'automotive software factory build placeholder'"
    }
  }
}

resource "huaweicloud_codearts_pipeline" "this" {
  count      = var.codearts_enabled ? 1 : 0
  name       = "${var.project_name}-pipeline"
  project_id = huaweicloud_codearts_project.this[0].id
  is_publish = false
  definition = <<-EOT
    version: "2.0"
    name: ${var.project_name}-pipeline
    stages:
      - stage: build
        jobs:
          - job: build_job
            steps:
              - task: shell
                script: "echo hello from ${var.project_name} pipeline"
  EOT
}
