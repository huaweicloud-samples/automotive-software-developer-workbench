# Packer 镜像工厂

用华为云官方维护的 [packer-plugin-huaweicloud](https://github.com/huaweicloud/packer-plugin-huaweicloud)
把 Windows 公共镜像制作成私有镜像，
作为镜像构建流水线使用。

## 前置条件

- Packer >= 1.10（`packer version`）
- 华为云 AK/SK（通过 `TF_VAR_*` 传入，勿写进文件）
- 已有 `infra/` 部署出的 VPC / 子网（或复用任意存量 VPC）

## 运行

```bash
# 1. 环境变量（不要落盘）
export HW_ACCESS_KEY="<HW_ACCESS_KEY>"
export HW_SECRET_KEY="<HW_SECRET_KEY>"
export HW_REGION_NAME="cn-north-4"
export PKR_VAR_winrm_password="<临时Administrator密码，需满足复杂度>"

# 2. 参数
export PKR_VAR_vpc_id="<infra 输出的 vpc_id>"
export PKR_VAR_subnet_id="<私网子网 id，需可出网>"
# 源镜像：控制台「镜像服务-公共镜像」查 Windows Server 2022 的镜像 ID，或：
#   terraform console 里 data.huaweicloud_images_image.windows 的 id

# 3. 执行
packer init .
packer validate .
packer build .
```

产物：IMS 私有镜像 `automotive-workbench-win-<时间戳>`，可在 ECS 控制台/terraform
`data.huaweicloud_images_image` 中按名称引用。

## 已知限制

- ⚠️ 模板按 packer-plugin-huaweicloud 官方参数编写，但在本机环境无法下载 packer
  二进制做 `packer validate`，首次运行请先 `packer validate` 确认 schema。
- 本模板只产出「基础 Windows 私有镜像」；特定行业工具链需由供应商提供
  华为云侧镜像后，在 `build.pkr.hcl` 中追加 provisioner 补装。
- Windows 构建依赖 WinRM，公共镜像默认未开启，`files/bootstrap-winrm.ps1`
  通过 Cloudbase-init user_data 在构建临时 ECS 上开启（HTTP + Basic Auth，
  仅限构建环境；生产安全组默认不放行 5985）。
