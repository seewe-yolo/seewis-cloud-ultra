# 一键导入 seewis-cloud-plus 的 Nacos 配置（Windows PowerShell 5.1+）
# 用法: powershell -ExecutionPolicy Bypass -File .\import-nacos-config.ps1
# 环境变量:
#   NACOS_ADDR        Nacos 地址                (默认 http://localhost:8848)
#   NACOS_USER        用户名                    (默认 nacos)
#   NACOS_PASS        密码                      (未设置时交互输入)
#   NACOS_NAMESPACES  目标命名空间 ID，逗号分隔  (默认 dev,prod，不会导入 public)
# 依赖: Windows 10 1803+ 自带的 curl.exe；Linux/macOS 请使用同目录下的 import-nacos-config.sh

$ErrorActionPreference = "Stop"

$NacosAddr = if ($env:NACOS_ADDR) { $env:NACOS_ADDR } else { "http://localhost:8848" }
$NacosUser = if ($env:NACOS_USER) { $env:NACOS_USER } else { "nacos" }
$Group = "DEFAULT_GROUP"
$Namespaces = if ($env:NACOS_NAMESPACES) { $env:NACOS_NAMESPACES } else { "dev,prod" }

$ConfigDir = $PSScriptRoot
if (-not $ConfigDir) { $ConfigDir = Split-Path -Parent $MyInvocation.MyCommand.Path }

if ($env:NACOS_PASS) {
    $NacosPass = $env:NACOS_PASS
} else {
    $secure = Read-Host "请输入 Nacos 密码($NacosUser)" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { $NacosPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

$files = @(Get-ChildItem -Path $ConfigDir -Filter *.yml -File)
if ($files.Count -eq 0) {
    Write-Error "配置目录下没有 yml 文件: $ConfigDir"
    exit 1
}

# Nacos 3.x: v1/v2 写接口已移除，配置发布走 v3 admin API

# ---------- 登录 ----------
$resp = & curl.exe -sf -m 10 -X POST "$NacosAddr/nacos/v1/auth/login" -d "username=$NacosUser&password=$NacosPass"
if (-not $resp -or $resp -notmatch '"accessToken":"([^"]+)"') {
    Write-Error "登录失败或未获取到 accessToken: $NacosAddr (检查地址/账号/网络) $resp"
    exit 1
}
$token = $Matches[1]
Write-Host "登录成功: $NacosUser @ $NacosAddr"

function Publish($ns, $file) {
    $out = & curl.exe -s -m 15 -X POST "$NacosAddr/nacos/v3/admin/cs/config" `
        --data-urlencode "dataId=$($file.Name)" `
        --data-urlencode "groupName=$Group" `
        --data-urlencode "namespaceId=$ns" `
        --data-urlencode "type=yaml" `
        --data-urlencode "content@$($file.FullName)" `
        --data-urlencode "accessToken=$token"
    return (($out -join "") -match '"code":0')
}

# ---------- 主流程 ----------
$totalFail = 0
foreach ($raw in $Namespaces.Split(",")) {
    $ns = $raw.Trim()
    if (-not $ns) { continue }
    Write-Host ">>> 导入到命名空间: $ns (group=$Group)"
    $ok = 0; $fail = 0
    foreach ($file in $files) {
        if (Publish $ns $file) {
            Write-Host "  [OK]   $($file.Name)"
            $ok++
        } else {
            Write-Host "  [FAIL] $($file.Name)"
            $fail++
        }
    }
    Write-Host "  命名空间 $ns 完成: 成功 $ok, 失败 $fail"
    $totalFail += $fail
}

Write-Host ""
Write-Host "全部完成: 命名空间 [$Namespaces]，失败总数 $totalFail"
exit $(if ($totalFail -eq 0) { 0 } else { 1 })
