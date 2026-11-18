# ============================================================
# 计算模块：Workers + Workbench（Windows ECS）
# Workbench 远程访问：EIP + RDP，安全组锁定运维来源 IP
# 本模块交付 Windows ECS 实例；特定行业工具链需由供应商提供华为云侧
#   镜像后，在镜像工厂模板中追加安装步骤。
# ============================================================

# Workbench：开发者工作台（公网 RDP，经 EIP）
resource "huaweicloud_compute_instance" "workbench" {
  name               = "${var.project_name}-workbench"
  flavor_id          = var.workbench_instance_type
  image_id           = data.huaweicloud_images_image.windows.id
  availability_zone  = var.availability_zone
  security_group_ids = [huaweicloud_networking_secgroup.workbench.id]
  agency_name        = huaweicloud_identity_agency.ecs_obs.name
  admin_pass         = var.windows_admin_password

  network {
    uuid = huaweicloud_vpc_subnet.private.id
  }

  system_disk_type = "SSD"
  system_disk_size = 100

  tags = {
    project = var.project_name
    role    = "workbench"
  }
}

# Workbench EIP 关联（RDP 入口）
resource "huaweicloud_compute_eip_associate" "workbench" {
  public_ip   = huaweicloud_vpc_eip.workbench.address
  instance_id = huaweicloud_compute_instance.workbench.id
}

# Workers：构建/仿真节点（私网，仅同 VPC 可达）
resource "huaweicloud_compute_instance" "workers" {
  count              = 1
  name               = "${var.project_name}-worker-${count.index}"
  flavor_id          = var.worker_instance_type
  image_id           = data.huaweicloud_images_image.windows.id
  availability_zone  = var.availability_zone
  security_group_ids = [huaweicloud_networking_secgroup.private.id]
  agency_name        = huaweicloud_identity_agency.ecs_obs.name
  admin_pass         = var.windows_admin_password

  network {
    uuid = huaweicloud_vpc_subnet.private.id
  }

  system_disk_type = "SSD"
  system_disk_size = 100

  tags = {
    project = var.project_name
    role    = "worker"
  }
}
