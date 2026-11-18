variable "region" {
  description = "华为云区域"
  type        = string
  default     = "cn-north-4"
}

variable "project_name" {
  description = "项目名前缀（用于资源命名）"
  type        = string
  default     = "automotive-workbench"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

# 部署前务必把默认值改为你的固定出口 IP（仅 RDP/SSH 入口需要收敛来源 IP）。
variable "admin_source_cidr" {
  description = "允许 RDP(3389)/SSH 访问的运维源 IP 段（禁止 0.0.0.0/0 用于生产）"
  type        = list(string)
  default     = ["0.0.0.0/0"] # ⚠️ 部署前改为你的固定运维 IP
}

variable "worker_instance_type" {
  description = "Workers ECS 规格（Windows 需 >=2vCPU/8GB）"
  type        = string
  default     = "s6.large.4"
}

variable "workbench_instance_type" {
  description = "Workbench ECS 规格（Windows 需 >=2vCPU/8GB）"
  type        = string
  default     = "s6.large.4"
}

variable "windows_os_version" {
  description = "Windows 公共镜像版本（cn-north-4 实测最新为 2019，按区域调整）"
  type        = string
  default     = "2019"
}

variable "rabbitmq_password" {
  description = "RabbitMQ 管理员密码（仅占位，建议 apply 时用 -var 或 TF_VAR 注入，勿提交明文）"
  type        = string
  sensitive   = true
  default     = "ChangeMe#2026"
}

variable "windows_admin_password" {
  description = "Windows ECS 管理员(Administrator)密码（apply 时用 -var 或 TF_VAR 注入，勿提交明文；需满足复杂度）"
  type        = string
  sensitive   = true
  default     = "ChangeMe#2026Abc"
}

variable "availability_zone" {
  description = "可用区（需与区域匹配）"
  type        = string
  default     = "cn-north-4a"
}

variable "codearts_enabled" {
  description = "是否创建 CodeArts（需账号先在控制台开通 CodeArts/ProjectMan 服务；未开通时 PM.02100546）"
  type        = bool
  default     = false
}
