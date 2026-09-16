# vivarcus CLI 使用指南

## 简介

`vivarcus` 是 Vivarcus 平台的命令行工具，用于操作 Domain、Vault、对象记录、组件元数据等资源。

## 快速开始

```bash
# 登录（OAuth Device Flow）
vivarcus auth login --endpoint http://127.0.0.1:8080

# 查看状态
vivarcus auth status
```

## 配置管理

配置文件位于 `~/.config/vivarcus/config.yaml`：

```yaml
profiles:
  default:
    endpoint: http://127.0.0.1:8080
    token: ""
    default_format: table
    default_vault: ""
```

支持多 profile 切换：`vivarcus --profile prod config list`

环境变量（优先级低于 flag）：

| 变量 | 对应配置 |
|------|----------|
| `VIVARCUS_TOKEN` | token |
| `VIVARCUS_ENDPOINT` | endpoint |
| `VIVARCUS_VAULT` | default_vault |

### 子命令

```bash
vivarcus config list                          # 列出所有 profile
vivarcus config get endpoint                  # 获取当前 profile 的值
vivarcus config set default_vault <vault-id>  # 设置值
```

## 全局 Flags

| Flag | 简写 | 类型 | 说明 |
|------|------|------|------|
| `--token` | | string | API Key / PAT |
| `--endpoint` | | string | API 端点 URL |
| `--profile` | `-p` | string | 配置 profile（默认 `default`） |
| `--json` | | bool | JSON 格式输出 |
| `--table` | | bool | 强制表格输出 |
| `--quiet` | `-q` | bool | 最小输出（仅 ID） |
| `--verbose` | `-v` | bool | 调试输出 |
| `--confirm` | | bool | 跳过删除确认 |
| `--version` | | bool | 打印版本信息 |

`--json`、`--table`、`--quiet` 互斥。若无显式指定，使用 profile 的 `default_format`（默认 `table`）。

## 认证

### vivarcus auth login

发起 OAuth Device Flow 登录，认证成功后将 token 写入当前 profile。

```bash
vivarcus auth login --endpoint http://127.0.0.1:8080
```

| Flag | 说明 |
|------|------|
| `--scopes` | PAT 权限范围（默认 `object:read,object:write,domain:read,component:read,security:token_create`） |
| `--no-browser` | 不自动打开浏览器 |

### vivarcus auth logout

```bash
vivarcus auth logout
```

### vivarcus auth status

```bash
vivarcus auth status
# 输出: Logged in as <user-id> (profile "default")
```

## Domain

```bash
# 列出可访问的 domain
vivarcus domain list

# 获取指定 domain
vivarcus domain get <domain-id>
```

## Vault

### 基本操作

```bash
# 列出 vault
vivarcus vault list

# 获取指定 vault
vivarcus vault get <vault-id>
```

### Sandbox

```bash
# 列出 sandbox
vivarcus vault sandbox list --vault <parent-vault-id>

# 获取指定 sandbox
vivarcus vault sandbox get <sandbox-id> --vault <parent-vault-id>

# 创建 sandbox（从源 vault）
vivarcus vault sandbox create \
  --vault <parent-vault-id> \
  --source-vault <source-vault-id> \
  --domain <domain-id> \
  --name my-sandbox \
  --size Small \
  --wait

# 创建 sandbox（从快照）
vivarcus vault sandbox create \
  --source-snapshot <snapshot-api-name> \
  --domain <domain-id> \
  --name from-snapshot

# 刷新 sandbox
vivarcus vault sandbox refresh <sandbox-id> \
  --vault <parent-vault-id> \
  --source-vault <source-vault-id>

# 删除 sandbox
vivarcus vault sandbox delete <sandbox-id> --confirm
```

Sandbox create 参数：

| Flag | 必填 | 说明 |
|------|------|------|
| `--source-vault` | 三选一 | 源 production vault ID |
| `--source-sandbox` | 三选一 | 源 sandbox vault ID |
| `--source-snapshot` | 三选一 | 源 snapshot api_name |
| `--domain` | 是 | Sandbox 所属 domain |
| `--name` | 是 | Sandbox 名称 |
| `--size` | | 规格（默认 `Small`） |
| `--release` | | 目标版本（默认 `General Release`） |
| `--region` | | 数据驻留区域 |
| `--set-owner` | | 授予当前用户 Vault Owner 权限 |

Sandbox delete 参数：

| Flag | 说明 |
|------|------|
| `--delete-snapshots` | 同时删除关联的 snapshot |
| `--change-snapshot-source` | 将 snapshot 转移到其他 sandbox |

### Snapshot

```bash
# 列出 sandbox 的 snapshot
vivarcus vault sandbox snapshot list <sandbox-id>

# 获取指定 snapshot
vivarcus vault sandbox snapshot get <snapshot-id>

# 创建 snapshot
vivarcus vault sandbox snapshot create <sandbox-id> \
  --name v1-snapshot \
  --description "Release v1" \
  --wait

# 更新（重建）snapshot
vivarcus vault sandbox snapshot update <snapshot-id>

# 删除 snapshot
vivarcus vault sandbox snapshot delete <snapshot-id> --confirm
```

Snapshot create 参数：

| Flag | 必填 | 说明 |
|------|------|------|
| `--name` | 是 | Snapshot 名称 |
| `--description` | | 描述 |
| `--include-data` | | 包含业务数据（源必须是 sandbox；对生产 Vault 打快照请联系平台管理员） |

### 异步操作

`vault sandbox create`、`refresh`、`snapshot create`、`snapshot update` 均为异步操作，支持以下 flag：

| Flag | 说明 |
|------|------|
| `--wait <duration>` | 最长等待时间，如 `30s`、`5m`、`1h`（默认无限等待） |
| `--no-wait` | 提交后立即返回 |
| `--no-progress` | 不显示进度信息 |

## Object CRUD

```bash
# 列出对象记录
vivarcus object list <object> --vault <vault-id>
vivarcus object list <object> --fields "id,name__v,status__v" --limit 50

# 获取单条记录
vivarcus object get <object> <record-id>
vivarcus object get <record-id> --object <object>

# 创建记录（JSON 文件）
vivarcus object create <object> --file record.json

# 单条: {"name__v": "example"}
# 批量: [{"name__v": "a"}, {"name__v": "b"}]

# 从 stdin 创建
echo '{"name__v": "hello"}' | vivarcus object create <object> --file -

# 更新记录
vivarcus object update <object> <record-id> --file update.json

# 删除记录
vivarcus object delete <object> <record-id> --confirm

# VQL 查询
vivarcus object query -q "SELECT id, name__v FROM <object> WHERE status__v = 'active__v'"
vivarcus object query --file query.vql

# 切换对象类型
vivarcus object switch-type <object> <record-id> --object-type <target-type>
```

## Object 元数据

```bash
# Schema
vivarcus object schema list
vivarcus object schema get <object-name>
vivarcus object schema get <object-name> --include-mdl

# Picklist
vivarcus object picklist list
vivarcus object picklist get <picklist-name>
vivarcus object picklist update <picklist-name> --file update.json
```

## Component

```bash
# 列出组件（可按类型过滤）
vivarcus component list
vivarcus component list --type Object

# 获取组件
vivarcus component get Object <component-name>
vivarcus component get Object <component-name> --include-mdl

# 创建组件（从 JSON 属性文件）
vivarcus component create Picklist my-picklist --file attrs.json

# 应用 MDL
vivarcus component apply-mdl --file changes.mdl
```

## Security

```bash
# 用户管理
vivarcus security user list --vault <vault-id>
vivarcus security user list --limit 50
vivarcus security user get <user-record-id>

# 角色管理
vivarcus security role list --vault <vault-id>

# 分配角色给用户
vivarcus security role assign \
  --user <user-record-id> \
  --role <application-role-id> \
  --status active__v

# 从 MDL 文件分配角色权限
vivarcus security role assign --file role.mdl
```

## Lifecycle

```bash
# 查看记录可用的生命周期动作
vivarcus lifecycle actions <object> <record-id>

# 执行生命周期转换
vivarcus lifecycle transition <object> <record-id> --action approve__v
```

## Object Action

```bash
# 执行对象记录动作（如创建草稿）
vivarcus action execute <object> <record-id> --action create_draft__v
```

## Operation

```bash
# 查看异步操作状态
vivarcus operation status <operation-id>

# 列出当前用户的操作
vivarcus operation list
vivarcus operation list --status failed
```

`--status` 可选值：`pending`、`running`、`success`、`failed`、`cancelled`

## 输出格式

| 模式 | Flag | 行为 |
|------|------|------|
| 默认表格 | （默认） | 人类可读表格 |
| JSON | `--json` | 美化 JSON 输出 |
| 静默 | `--quiet` | 仅打印 ID，适合脚本 |

配置默认格式：

```bash
vivarcus config set default_format json
```

## 错误处理

退出码：

| 码 | 含义 |
|----|------|
| 0 | 成功 |
| 1 | 参数或输入错误 |
| 2 | 认证/授权失败 |
| 3 | 服务端错误 |
| 4 | 资源冲突 |
| 5 | 速率限制 |
| 6 | 资源未找到 |

## 命令速查表

```
vivarcus [--profile,-p <name>] [--token <pat>] [--endpoint <url>]
  [--json|--table|--quiet,-q] [--verbose,-v] [--confirm] [--version]

认证
  vivarcus auth login  [--scopes <scopes>] [--no-browser]
  vivarcus auth logout
  vivarcus auth status

配置
  vivarcus config list
  vivarcus config get  <key>
  vivarcus config set  <key> <value>

Domain
  vivarcus domain list
  vivarcus domain get  <domain-id>

Vault
  vivarcus vault list
  vivarcus vault get   <vault-id>
  vivarcus vault sandbox create   [flags]             # 异步
  vivarcus vault sandbox refresh  <sandbox-id> [flags] # 异步
  vivarcus vault sandbox delete   <sandbox-id>
  vivarcus vault sandbox list
  vivarcus vault sandbox get      <sandbox-id>
  vivarcus vault sandbox snapshot create  <sandbox-id> [flags]  # 异步
  vivarcus vault sandbox snapshot update  <snapshot-id> [flags]  # 异步
  vivarcus vault sandbox snapshot delete  <snapshot-id>
  vivarcus vault sandbox snapshot list    <sandbox-id>
  vivarcus vault sandbox snapshot get     <snapshot-id>

Object
  vivarcus object list     <object>
  vivarcus object get      <object> <record-id>
  vivarcus object create   <object>       [-f <file>]
  vivarcus object update   <object> <id>  [-f <file>]
  vivarcus object delete   <object> <id>
  vivarcus object query    [-q <vql> | -f <file>]
  vivarcus object schema list
  vivarcus object schema get  <name>
  vivarcus object picklist list
  vivarcus object picklist get  <name>
  vivarcus object picklist update <name>  [-f <file>]
  vivarcus object switch-type <object> <id> --object-type <type>

Component
  vivarcus component list     [--type <type>]
  vivarcus component get      <type> <name>  [--include-mdl]
  vivarcus component create   <type> <name>  [-f <attrs.json>]
  vivarcus component apply-mdl               [-f <file>]

Security
  vivarcus security user list
  vivarcus security user get   <user-record-id>
  vivarcus security role list
  vivarcus security role assign  [--user <id> --role <id> | -f <mdl>]

Lifecycle
  vivarcus lifecycle actions     <object> <record-id>
  vivarcus lifecycle transition  <object> <record-id> --action <action>

Action
  vivarcus action execute  <object> <record-id> --action <action>

Operation
  vivarcus operation status  <operation-id>
  vivarcus operation list    [--status <status>]
```
