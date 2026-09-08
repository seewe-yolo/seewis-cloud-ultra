#!/usr/bin/env bash
# 一键导入 seewis-cloud-plus 的 Nacos 配置（Linux / macOS）
# 用法: ./import-nacos-config.sh
# 环境变量:
#   NACOS_ADDR        Nacos 地址                (默认 http://localhost:8848)
#   NACOS_USER        用户名                    (默认 nacos)
#   NACOS_PASS        密码                      (未设置时交互输入，避免密码进 shell 历史)
#   NACOS_NAMESPACES  目标命名空间 ID，逗号分隔  (默认 dev,prod，不会导入 public)
# Windows 请使用同目录下的 import-nacos-config.ps1

set -euo pipefail

NACOS_ADDR="${NACOS_ADDR:-http://localhost:8848}"
NACOS_USER="${NACOS_USER:-nacos}"
GROUP="DEFAULT_GROUP"
NACOS_NAMESPACES="${NACOS_NAMESPACES:-dev,prod}"

# Nacos 3.x: v1/v2 写接口已移除，配置发布走 v3 admin API

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="${CONFIG_DIR:-$SCRIPT_DIR}"

IFS=',' read -r -a NAMESPACES <<< "$NACOS_NAMESPACES"

if [[ -z "${NACOS_PASS:-}" ]]; then
  read -rsp "请输入 Nacos 密码($NACOS_USER): " NACOS_PASS; echo
fi

# ---------- 登录 ----------
login() {
  local resp
  resp=$(curl -sf -m 10 -X POST "$NACOS_ADDR/nacos/v1/auth/login" \
    -d "username=$NACOS_USER" -d "password=$NACOS_PASS") || {
    echo "登录失败: $NACOS_ADDR (检查地址/账号/网络)" >&2
    exit 1
  }
  ACCESS_TOKEN=$(echo "$resp" | sed -n 's/.*"accessToken":"\([^"]*\)".*/\1/p')
  [[ -n "$ACCESS_TOKEN" ]] || { echo "未获取到 accessToken: $resp" >&2; exit 1; }
  echo "登录成功: $NACOS_USER @ $NACOS_ADDR"
}

# ---------- 检查命名空间是否存在（接口不可用或解析失败时仅跳过检查，不阻断导入） ----------
check_namespaces() {
  local resp ids ns
  resp=$(curl -sf -m 10 "$NACOS_ADDR/nacos/v3/admin/core/namespace/list?pageNo=1&pageSize=100&accessToken=$ACCESS_TOKEN" || true)
  [[ -z "$resp" ]] && return 0
  ids=$(echo "$resp" | grep -o '"namespaceId":"[^"]*"' | sed 's/"namespaceId":"//;s/"$//' || true)
  [[ -z "$ids" ]] && return 0
  for ns in "${NAMESPACES[@]}"; do
    if ! echo "$ids" | grep -qx "$ns"; then
      echo "  [警告] 命名空间 [$ns] 未在 Nacos 中找到，请先在控制台创建（命名空间 ID 需为 $ns）" >&2
    fi
  done
}

# ---------- 发布单个配置 ----------
publish() {
  local ns="$1" file="$2" dataId resp
  dataId=$(basename "$file")
  resp=$(curl -sf -m 15 -X POST "$NACOS_ADDR/nacos/v3/admin/cs/config" \
    --data-urlencode "dataId=$dataId" \
    --data-urlencode "groupName=$GROUP" \
    --data-urlencode "namespaceId=$ns" \
    --data-urlencode "type=yaml" \
    --data-urlencode "content@$file" \
    --data-urlencode "accessToken=$ACCESS_TOKEN") || return 1
  echo "$resp" | grep -q '"code":0'
}

# ---------- 主流程 ----------
[[ -d "$CONFIG_DIR" ]] || { echo "配置目录不存在: $CONFIG_DIR" >&2; exit 1; }

shopt -s nullglob
files=("$CONFIG_DIR"/*.yml)
shopt -u nullglob
[[ ${#files[@]} -gt 0 ]] || { echo "配置目录下没有 yml 文件: $CONFIG_DIR" >&2; exit 1; }

login
check_namespaces

total_fail=0
for ns in "${NAMESPACES[@]}"; do
  echo ">>> 导入到命名空间: $ns (group=$GROUP)"
  ok=0; fail=0
  for file in "${files[@]}"; do
    dataId=$(basename "$file")
    if publish "$ns" "$file"; then
      echo "  [OK]   $dataId"
      ok=$((ok+1))
    else
      echo "  [FAIL] $dataId" >&2
      fail=$((fail+1))
    fi
  done
  echo "  命名空间 $ns 完成: 成功 $ok, 失败 $fail"
  total_fail=$((total_fail+fail))
done

echo
echo "全部完成: 命名空间 [$NACOS_NAMESPACES]，失败总数 $total_fail"
[[ $total_fail -eq 0 ]]
