# 部署指导书：Automotive Software Developer Workbench on Huawei Cloud

> 本文档提供从零部署本实践的逐步命令与预期输出。所有命令使用相对路径，请在仓库根目录执行。

## 1. 前置条件

- 华为云账号，目标区域（默认 `cn-north-4`）已开通 ECS、VPC、DMS、OBS 等服务权限。
- 访问密钥通过 `TF_VAR_*` 在部署命令中传入（**禁止写入任何文件**）：

  ```bash
  export HW_ACCESS_KEY="<HW_ACCESS_KEY>"
  export HW_SECRET_KEY="<HW_SECRET_KEY>"
  export HW_REGION_NAME="cn-north-4"
  ```

- 本地安装 Terraform ≥ 1.9（huaweicloud provider ≥ 1.60）。
- 区域约束：`cn-north-4` 公共镜像的 Windows Server 版本为 **2019**，由 `windows_os_version` 变量控制。

> ⚠️ **公网入口告知**：Workbench 通过弹性公网 IP（EIP）提供 RDP 远程桌面入口，隶属于公网入口。部署前请务必将 `variables.tf` 中 `admin_source_cidr` 默认值 `0.0.0.0/0` 收紧为你的固定出口 IP，避免 RDP 对全网开放。

## 2. 部署基础设施（Terraform）

```bash
cd infra

# 2.1 初始化（下载 huaweicloud provider）
terraform init
```

预期：`Initializing the backend...` / `Terraform has been successfully initialized!`

```bash
# 2.2 预览变更
terraform plan -var 'windows_admin_password=<你的密码>' -var 'rabbitmq_password=<你的密码>'
```

预期：输出资源增删改计划，`Plan: 24 to add, 0 to change, 0 to destroy`。

```bash
# 2.3 部署
terraform apply -var 'windows_admin_password=<你的密码>' -var 'rabbitmq_password=<你的密码>'
```

预期：退出前提示 `Apply complete! Resources: 24 added, 0 changed, 0 destroyed`。

### 关键变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `region` | `cn-north-4` | 部署区域 |
| `project_name` | `automotive-workbench` | 资源命名前缀 |
| `admin_source_cidr` | `0.0.0.0/0` ⚠️ | RDP/SSH 来源 IP 白名单，**部署前必须收紧** |
| `worker_instance_type` / `workbench_instance_type` | `s6.large.4` | ECS 规格 |
| `windows_os_version` | `2019` | Windows 公共镜像版本 |
| `codearts_enabled` | `false` | 是否创建 CodeArts 流水线（需账号先开通 CodeArts 服务） |
| `windows_admin_password` / `rabbitmq_password` | 占位 | 敏感项，建议运行时注入 |

## 3. 使用与验证

### 3.1 远程桌面登录 Workbench

```text
mstsc /v:<workbench_eip>:3389
用户：Administrator
密码：部署时注入的 windows_admin_password（terraform output workbench_rdp_hint 可查看提示）
```

### 3.2 验证消息队列端到端（Workbench → RabbitMQ 生产/消费）

在 Workbench 的命令行中执行（RabbitMQ 管理 API，认证通过即证明内网连通与实例正常）：

```bash
# 查看实例状态（返回 JSON 即通过）
curl -u <rabbit_user>:<rabbit_password> "http://<rabbitmq_host>:15672/api/overview"

# 建队列 → 发消息 → 取消息（三步闭环）
curl -u <rabbit_user>:<rabbit_password> -X PUT "http://<rabbitmq_host>:15672/api/queues/%2F/workbench_demo" -H "Content-Type: application/json" -d "{\"durable\":false}"
curl -u <rabbit_user>:<rabbit_password> -X POST "http://<rabbitmq_host>:15672/api/exchanges/%2F/amq.default/publish" -H "Content-Type: application/json" -d "{\"properties\":{},\"routing_key\":\"workbench_demo\",\"payload\":\"hello from workbench\",\"payload_encoding\":\"string\"}"
curl -u <rabbit_user>:<rabbit_password> -X POST "http://<rabbitmq_host>:15672/api/queues/%2F/workbench_demo/get" -H "Content-Type: application/json" -d "{\"count\":5,\"ackmode\":\"ack_requeue_false\",\"encoding\":\"auto\"}"
```

预期：`routed:true` 表示消息成功入队；取消息步骤能回读原始 payload 即验证通过。Workbench / Workers 的私有 IP 与 RabbitMQ 内网地址可通过 `terraform output` 查看。

## 4. （可选）制作 Windows 私有镜像（Packer）

```bash
cd packer

# 环境变量（不要落盘）
export HW_ACCESS_KEY="<HW_ACCESS_KEY>"
export HW_SECRET_KEY="<HW_SECRET_KEY>"
export HW_REGION_NAME="cn-north-4"
export PKR_VAR_winrm_password="<临时Administrator密码，需满足复杂度>"

# 参数
export PKR_VAR_vpc_id="<infra 输出的 vpc_id>"
export PKR_VAR_subnet_id="<私网子网 id，需可出网>"
# 源镜像：控制台「镜像服务-公共镜像」查 Windows Server 的镜像 ID，或从 infra 用
#   terraform console 读取 data.huaweicloud_images_image.windows 的 id

# 执行
packer init .
packer validate .
packer build .
```

产物：IMS 私有镜像 `automotive-workbench-win-<时间戳>`，可在 ECS 控制台或 Terraform `data.huaweicloud_images_image` 中按名称引用。

> 说明：构建临时 ECS 通过 WinRM 通信，公共镜像默认未开启，由 `files/bootstrap-winrm.ps1` 通过 Cloudbase-init user_data 在构建环境开启（仅限构建期；生产安全组默认不放行 5985）。

## 5. 清理资源

```bash
cd infra
terraform destroy
```

> 删除全部资源（ECS / EIP / DMS / OBS / VPC 等）。OBS 桶已设 `force_destroy=true`，可直接删除。

## 6. 常见问题

- **CodeArts 报 `PM.02100546 该企业租户服务处于关闭状态`**：账号未开通 CodeArts / ProjectMan 服务，需先在控制台开通，再置 `codearts_enabled=true` 重新 apply。
- **DMS 创建报 `DMS.00400009 Product not found`**：规格须通过 `huaweicloud_dms_product` 数据源按区域自动匹配，勿手写规格 ID。
- **找不到 Windows 2022 公共镜像**：`cn-north-4` 区域最新公共镜像为 Windows Server 2019，调整 `windows_os_version` 即可。
- **RDP 连不上**：确认安全组 `admin_source_cidr` 包含你的出口 IP；实例刚创建时等待 3–5 分钟完成初始化。
