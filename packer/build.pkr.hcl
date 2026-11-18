# ============================================================
# 镜像工厂：Packer 构建 Windows 基础镜像
#
# 用法（需先有 infra 的 VPC/子网）：
#   export HW_ACCESS_KEY=... HW_SECRET_KEY=... HW_REGION_NAME=cn-north-4
#   export PKR_VAR_winrm_password='<临时构建密码>'
#   packer init . && packer validate . && packer build .
#
# 说明：此处只产出「基础 Windows 私有镜像」；特定行业工具链需由供应商
#       提供华为云侧镜像后，在本模板中追加 provisioner 补装。
# ============================================================

packer {
  required_plugins {
    huaweicloud = {
      version = ">= 1.0.0"
      source  = "github.com/huaweicloud/huaweicloud"
    }
  }
}

variable "region" {
  type    = string
  default = "cn-north-4"
}

variable "availability_zone" {
  type    = string
  default = "cn-north-4a"
}

variable "vpc_id" {
  type        = string
  description = "构建临时 ECS 所在 VPC（复用 infra/ 输出）"
}

variable "subnet_id" {
  type        = string
  description = "构建临时 ECS 所在子网（复用 infra/ 私网子网，需可出网）"
}

variable "source_image" {
  type        = string
  description = "源 Windows 公共镜像 ID（可在控制台镜像服务查询，或用 huaweicloud_images_image 数据源）"
}

variable "flavor" {
  type    = string
  default = "s6.large.4"
}

variable "image_name_prefix" {
  type    = string
  default = "automotive-workbench-win"
}

variable "winrm_password" {
  type        = string
  sensitive   = true
  description = "临时 ECS 的 Administrator 密码（构建时用 PKR_VAR_winrm_password 注入，勿提交明文）"
}

source "huaweicloud-ecs" "windows" {
  region             = var.region
  availability_zone  = var.availability_zone
  vpc_id             = var.vpc_id
  subnet_id          = var.subnet_id
  flavor             = var.flavor
  image_name         = "${var.image_name_prefix}-${formatdate("YYYYMMDDhhmm", timestamp())}"
  source_image       = var.source_image
  eip_type           = "5_bgp"
  eip_bandwidth_size = 5

  # Windows 通信：WinRM（公共镜像默认未开，由 user_data 通过 Cloudbase-init 开启）
  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = var.winrm_password
  admin_pass     = var.winrm_password
  user_data_file = "files/bootstrap-winrm.ps1"
}

build {
  sources = ["source.huaweicloud-ecs.windows"]

  # 占位：接入实际 ETAS 工具链后在此追加 provisioner（如 install ETAS ASCET/EHANDBOOK）
  provisioner "powershell" {
    inline = [
      "Write-Output 'Automotive Workbench base image - provisioned by Packer'"
    ]
  }
}
