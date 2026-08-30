# Nacos 配置说明

本目录存放 seewis-cloud-plus 各服务的 Nacos 配置种子文件，并提供一键导入脚本（支持 dev / prod 双命名空间）。

## 文件清单

| 文件 | 说明 | 导入前通常需要修改 |
|---|---|---|
| `application-common.yml` | 所有服务共享的公共配置 | `spring.data.redis`（host/port/password）、`spring.rabbitmq`、`sa-token.jwt-secret-key`（务必换成自己的随机串）、监控账号（nacos discovery metadata） |
| `datasource.yml` | 数据库连接 | 各库 jdbc 地址/账号/密码（system / job / ai / workflow） |
| `ruoyi-auth.yml` | 认证服务 | `security.captcha`（验证码开关与类型）、`security.xcx.apps`（小程序 appid/密钥兜底配置，正式建议用参数管理 `sys.account.xcxApps`）、`justauth`（三方登录密钥） |
| `ruoyi-gateway.yml` | 网关 | `security.ignore.whites`（放行白名单）、路由规则 |
| `ruoyi-system.yml` | 系统模块 | `spring.liquibase.enabled`：**全新空库首次启动改为 `true`** 初始化表结构和种子数据，初始化完成后建议改回 `false` |
| `ruoyi-resource.yml` / `ruoyi-job.yml` / `ruoyi-workflow.yml` / `ruoyi-gen.yml` / `ruoyi-ai.yml` / `ruoyi-snailai-server.yml` / `ruoyi-snailjob-server.yml` | 对应模块 | 各自的 liquibase 开关、第三方参数，按需修改 |
| `ruoyi-monitor.yml` | SpringBoot Admin 监控 | 监控服务账号密码，按需修改 |
| `seata-server.properties` | Seata 服务端配置 | 脚本只导入 `*.yml`，此文件需手动在 Nacos 控制台创建（dataId `seata-server.properties`，group `DEFAULT_GROUP`，类型 `properties`） |

> 注意：**导入会覆盖服务器上 dataId 相同的同名配置**（按 dataId 全量覆盖），服务器上已有个性化修改的配置请先备份或在控制台核对差异。

## 命名空间

- 默认导入到 **`dev` 和 `prod`** 两个命名空间，**不会**导入 `public`。
- 需要先在 Nacos 控制台创建命名空间，**命名空间 ID 必须为 `dev` / `prod`**；如使用其他 ID，通过环境变量 `NACOS_NAMESPACES` 指定（如 `NACOS_NAMESPACES=dev-id-1,prod-id-2`）。
- 服务的注册与配置拉取必须使用相同命名空间：各服务 `application.yml` / maven profile 中的 `spring.cloud.nacos.discovery.namespace` 与 `spring.cloud.nacos.config.namespace` 需与目标命名空间 ID 一致，否则服务找不到配置。

## 导入脚本

脚本与本目录的 yml 放在一起，自动导入当前目录下所有 `*.yml`。

### Linux / macOS

```bash
chmod +x import-nacos-config.sh
./import-nacos-config.sh
```

### Windows（PowerShell 5.1+，Win10 1803+ 自带 curl.exe）

```powershell
powershell -ExecutionPolicy Bypass -File .\import-nacos-config.ps1
```

### 环境变量（两个脚本通用）

| 变量 | 说明 | 默认值                      |
|---|---|--------------------------|
| `NACOS_ADDR` | Nacos 地址 | `http://localhost:8848`  |
| `NACOS_USER` | 用户名 | `nacos`                  |
| `NACOS_PASS` | 密码 | 未设置时交互输入（避免密码进 shell 历史） |
| `NACOS_NAMESPACES` | 目标命名空间 ID，逗号分隔 | `dev,prod`               |

示例：只导入到 dev，指向本地 Nacos：

```bash
NACOS_ADDR=http://127.0.0.1:8848 NACOS_NAMESPACES=dev ./import-nacos-config.sh
```

脚本使用 Nacos 3.x 的 v3 admin API（v1/v2 写接口在 3.x 已移除）；密码输入优先走环境变量 `NACOS_PASS`，否则交互式输入。
