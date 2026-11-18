# ============================================================================
# 根模块入口（Root module entry）
# ============================================================================
# 本目录采用按职责拆分的单目录多文件结构组织 Terraform 配置。
# Terraform 会自动加载本目录下所有 *.tf 文件，因此无需在此重复声明资源。
#
# 各配置文件职责：
#   provider.tf / versions.tf   provider 与版本约束
#   variables.tf                输入变量与默认值
#   networking.tf               VPC / 子网 / EIP / 安全组
#   compute.tf                  Workbench 与 Workers（Windows ECS）
#   mq.tf                       DMS RabbitMQ 实例
#   storage.tf                  OBS 桶与凭据托管（CSMS）
#   security_iam.tf             IAM 委托（ECS 访问 OBS）
#   observability.tf            LTS 日志 / CTS 审计
#   codearts.tf                 CodeArts 流水线（可选，默认关闭）
#   data.tf                     数据源（公共镜像区域匹配）
#   outputs.tf                  输出值
# ============================================================================
