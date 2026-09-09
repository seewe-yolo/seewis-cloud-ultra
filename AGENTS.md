# Seewis Cloud Ultra 开发约定（团队共享）

> 本文件是团队级开发约定，随仓库分发。修改数据库相关规则时请同步更新各模块 changelog 结构。

## Liquibase 双通道规则（涉及数据库变更必须遵守）

六个模块（system / gen / job / resource / workflow / snailai-server）各自的 `src/main/resources/db/changelog/` 下：

```text
db.changelog-master.yaml   # master 通道：服务启动自动执行（基线 + 增量，持续迁移）
db.changelog-final.yaml    # finalbase 通道：手动执行，全新库一键全量初始化
mysql|postgresql/
├── liquibase/             # 带 changeset 的基线 + 增量（X_table.sql / X_data.sql / 增量 YYYY-MM-DD-NN-xxx.sql）
└── finalbase/             # 全量结构+数据快照（同样带 changeset），始终保持"最新完整"
```

1. 表结构/数据变更：只在 `liquibase/` 新增增量 changeset，并在 master yaml 按执行顺序**显式 include**（禁止 includeAll——字母序会把 data 排到 table 前面）。
2. 同一变更必须**同步手改 finalbase/ 对应文件**（改 CREATE TABLE / 补 INSERT），finalbase 永远保持最新全量；它的 changeset 只在全新库首次执行，内容改写不影响已建库。
3. **一个数据库一生只走一条通道，绝不混用**：master（默认）或 finalbase（一键建库/演示环境）。
4. finalbase 建的库要接入应用走 master 增量前，先对 master 执行 `changelog-sync` 对齐账本；master 通道的库永远不要再跑 final 通道（同表重复建）。
5. 漂移兜底：可用"跑完全部 changeset 的干净库 + mysqldump"重新生成 finalbase。
6. 每个变更需同时维护 mysql 与 postgresql 两份；system 模块 master 的 postgresql include 保持注释状态（历史现状，勿随手激活）。

## 其他约定

- 项目为单租户形态（多租户能力已裁剪）：workflow 的 `flow_*` 表 `tenant_id` 列是 warm-flow 引擎表结构，**保留勿删**；`SocialLoginConfigProperties.tenantId` 是 Microsoft OAuth 概念，与系统多租户无关。
- 数据库初始化完全由 Liquibase 接管，不要重建手工 SQL 脚本目录（原 `script/sql/` 已删除）。
- 提交信息使用**中英双语 Conventional Commits**（`<type>(scope): <summary>` + 双语正文），推送前需确认。
- 构建与验证：Maven 多模块，默认 dev profile（Nacos localhost:8848，`.run/` 有各服务启动配置）；根 pom `maven.test.skip=true` 仅影响打包，验证请显式运行测试。
- 新增第三方依赖前确认 Spring Boot 4.x 兼容性（本项目使用 Java 21 + Spring Boot 4.1 + Spring Cloud 2025.1 前沿版本组合）。
