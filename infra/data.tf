# ============================================================
# 数据源：Windows 公共镜像（使 apply 自包含，无需硬编码镜像 ID）
# 注意：同一 OS 在不同区域公共镜像 name 可能不同，
#       若 plan 报找不到镜像，请到目标区域控制台核对 Windows 2022 公共镜像全名。
# ============================================================

data "huaweicloud_images_image" "windows" {
  # 模糊匹配：兼容 Datacenter/DataCenter 等拼写变体。
  # 注意：cn-north-4 公共镜像最新仅到 Windows Server 2019（实测无 2022），
  #       版本由变量 windows_os_version 控制，可按区域调整。
  name_regex  = "Windows Server ${var.windows_os_version}"
  most_recent = true
  visibility  = "public"
}
