# ============================================================
# 日志 / 审计模块
# - LTS：日志组/日志流承接 Workers 写日志
# - CTS：审计追踪器，日志投递到 OBS audit 桶
#   注：本试点仅保留审计落盘能力，未建事件触发链。
# ============================================================

resource "huaweicloud_lts_group" "this" {
  group_name  = "${var.project_name}-group"
  ttl_in_days = 7
}

resource "huaweicloud_lts_stream" "workers" {
  group_id    = huaweicloud_lts_group.this.id
  stream_name = "${var.project_name}-workers"
}

# CTS 审计追踪器（审计日志落入 OBS audit 桶）
# 注：name/type 由系统生成（system 追踪器），不可显式配置
resource "huaweicloud_cts_tracker" "this" {
  bucket_name = huaweicloud_obs_bucket.audit.bucket
  file_prefix = "cts"
}
