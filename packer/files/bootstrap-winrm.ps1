<powershell>
# ============================================================
# 构建临时 Windows ECS 的引导脚本（Cloudbase-init user_data）
# 作用：开启 WinRM（HTTP + Basic Auth），供 Packer winrm communicator 连接
# 说明：华为云公共 Windows 镜像默认未启用 WinRM 监听
# ============================================================

# 快速配置 WinRM 默认服务
winrm quickconfig -q

# 允许 Basic 认证（Packer winrm 需要）
winrm set winrm/config/service/auth "@{Basic=`"true`"}"
# 允许未加密传输（构建环境内网使用；生产镜像请改用 HTTPS/自签证书）
winrm set winrm/config/service "@{AllowUnencrypted=`"true`"}"

# 防火墙放行 5985
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

# 关闭防火墙（构建临时 ECS 简化网络；镜像仅作为快照基准，正式使用仍走安全组）
netsh advfirewall set allprofiles state off

Write-Output "WinRM bootstrap completed"
</powershell>
