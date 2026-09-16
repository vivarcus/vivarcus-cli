# 部署 Inbound VPK（SDK Record Action）

配合 [vivarcus-sdk](https://github.com/vivarcus/vivarcus-sdk) 构建的 `gosdk/` VPK，用 `vivarcus` 导入、校验并部署。

## 前置

- 已安装与 Vault 版本对齐的 `vivarcus`（见仓库 [README](../README.md)）
- 已登录或配置 `VIVARCUS_TOKEN` / `VIVARCUS_ENDPOINT` / `VIVARCUS_VAULT`
- 目标对象与字段已通过 MDL 创建（Vault Owner 或等效 metadata 权限）

## 三步部署

```bash
# 1. 导入
vivarcus package import ./my-action.vpk --json
# 记录返回的 package_id

# 2. 校验
vivarcus package validate <package_id> --json
# deployment_status 不应为 not_verified__v

# 3. 部署（非 TTY 须 --confirm）
vivarcus package deploy <package_id> --confirm --json
# 期望 deployment_status 为 deployed__v
```

部署成功后平台会创建 **inactive** 的 `Recordaction` / `Objectaction`；须管理员 `ALTER ... active(true)` 后按钮才在 UI 出现。详见 vivarcus-sdk 文档中的 MDL 激活步骤。

## 权限

| 操作 | 所需权限 |
|------|----------|
| `vivarcus package import/validate/deploy` | `configuration.deployment` |
| `vivarcus component apply-mdl` | metadata 编辑权限 |

## 验证

1. 打开绑定对象的记录详情
2. **All Actions** 中应出现 manifest 中的 label
3. 执行后确认字段/横幅等业务效果
