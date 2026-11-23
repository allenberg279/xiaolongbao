# Alibaba Cloud Landing Zone — Terraform Starter

一个**面向未来一键部署**的轻量级阿里云 Landing Zone 基础工程，当前仅包含组织、基础网络和审计存储，**不创建 ACK / ECS / 业务应用，不部署 Helm**。

> 状态：Starter / Review Required。已按 Alibaba Cloud Terraform Provider 1.294.x 文档编写；尚未连接真实阿里云账号执行 `terraform plan/apply`。默认不自动部署。

## 架构与边界

| Stack | 管理的资源 | 部署账号 | 前置条件 |
| --- | --- | --- | --- |
| `organization` | 4 个顶层资源目录 Folder + 3 个 Workload 子 Folder | Resource Directory 管理账号 | 已开通 Resource Directory，具备管理权限 |
| `network` | 1 个 VPC + 自定义私网 vSwitch | 未来的 Network/Shared Services 账号 | Region、Zone、CIDR 规划 |
| `audit` | 私有 OSS Bucket、防公开访问、版本控制、AES256 加密、可选 ActionTrail | 未来的 Log Archive 账号 | 全局唯一 OSS Bucket 名、相关权限；开启 Trail 时需要投递角色 |

**不自动创建云账号、不变更企业账单、不启用付费安全产品。** 资源目录中的 Folder 不是云账号；如需三账号隔离（管理/网络/日志），先人工或通过后续 Account Factory 建立账号并配置跨账号角色。

## 首次准备

1. 确认账户已完成企业实名认证，并在管理账号中启用 Resource Directory（仅对 organization）。
2. 规划区域、可用区、CIDR（特别是与企业现有 VPC / IDC 网段不重叠）。
3. 为每个 Stack 的运行账号提供临时授权（本地建议 SSO/STS，GitHub 建议 RAM OIDC）；不要写 AccessKey 到代码或 Actions。
4. 在单独的 bootstrap 流程中准备 **私有且加密的 Terraform OSS State Bucket + Tablestore Lock 表**，Lock 表主键 `LockID`、类型 String。**这两个基础资源不由本仓库 Stack 自身管理**，避免自举循环依赖。
5. 复制各 Stack 的 `terraform.tfvars.example` 为未跟踪的 `terraform.tfvars` 并替换实际参数。
6. 确认 Terraform 1.10.x+ 和 Alibaba Cloud provider 1.294.x 可安装。

## 本地验证（不创建资源）

```bash
cd alicloud-landing-zone
bash scripts/validate.sh
```

## 本地试运行（以 network 为例）

```bash
cd alicloud-landing-zone/stacks/network
cp terraform.tfvars.example terraform.tfvars
# 修改 terraform.tfvars 中的 region / CIDR / zone_id
terraform init -backend=false
terraform validate
# 仅在具备阿里云授权后：
# terraform plan
```

生产级协作请使用远程状态，不要直接将本地 `terraform.tfstate` 上传 GitHub：

```bash
terraform init -reconfigure \
  -backend-config="bucket=YOUR_PRIVATE_STATE_BUCKET" \
  -backend-config="region=cn-hangzhou" \
  -backend-config="prefix=landing-zone/network" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="encrypt=true" \
  -backend-config="acl=private" \
  -backend-config="tablestore_endpoint=https://YOUR_OTS_INSTANCE.cn-hangzhou.ots.aliyuncs.com" \
  -backend-config="tablestore_table=YOUR_OTS_LOCK_TABLE"
terraform plan -input=false
```

`organization` 和 `audit` 应将 `prefix` 分别改为 `landing-zone/organization` 和 `landing-zone/audit`。跨账号部署时，各 Stack 使用各自对应的 RAM 角色，不能假设单个角色有全部账号权限。

## GitHub Actions

仓库根目录 `.github/workflows/alicloud-landing-zone.yml`：
- push/PR：只做 `terraform fmt -check`、`init -backend=false` 和 `validate`；不访问云资源。
- workflow_dispatch：在默认分支上手动选择 `organization` / `network` / `audit` 与 `plan` / `apply`。
- `apply`：除了手动触发，还必须配置 `LZ_ENABLE_APPLY=true` 且将 GitHub **alicloud-production Environment** 配置成必须审批。未经这些步骤不应启用 apply。
- 使用 GitHub OIDC + 阿里云 RAM 角色取得**临时**凭证，不使用长期 AccessKey。

需在 GitHub Repository Variables 中准备：
- `ALICLOUD_OIDC_PROVIDER_ARN`、`ALICLOUD_ROLE_ARN`（RAM 已建立 OIDC 信任，限定仓库/分支；Plan/Apply 生产环境应使用独立角色）
- `TF_STATE_BUCKET`、`TF_STATE_REGION`、`TF_TABLESTORE_ENDPOINT`、`TF_LOCK_TABLE`
- `LZ_REGION`、`LZ_NAME_PREFIX`、`LZ_VPC_CIDR`、`LZ_VSWITCHES_JSON`
- `LZ_AUDIT_BUCKET_NAME`、`LZ_ENABLE_ACTIONTRAIL`、`LZ_TRAIL_OSS_ROLE_ARN`
- `LZ_ENABLE_APPLY` 默认不设置或 false。

其中 `LZ_VSWITCHES_JSON` 举例：`{"private-a":{"zone_id":"cn-hangzhou-h","cidr_block":"10.20.1.0/24"}}`（仅示意；请核实实际可用区）。`LZ_AUDIT_BUCKET_NAME` 必须全球唯一。当前一个手动 Job 使用一个部署角色，仅适合该角色对目标 Stack 有明确权限的情况；未来推荐将管理账号、网络账号、日志账号分成独立 Workflows/Environments、不同 OIDC 角色及审批策略。

**注意：** GitHub 的 `workflow_dispatch` 必须存在于默认分支；本次隔离在独立分支的工作流不会立即成为默认分支的手动按钮。未来迁至独立仓库或合并工作流后，再启用这些功能。

## 上线前检查

- [ ] 实际创建 / 导入 Resource Directory 和成员账号，核对多账号管理架构
- [ ] 逐项审查最小权限 RAM Policy、OIDC 的 subject/audience 绑定
- [ ] 使用单独的 OSS/Tablestore 远程状态，启用备份、审计和加密
- [ ] 核实所有可用区、非重叠 CIDR、区域价格和产品配额
- [ ] 审查 ActionTrail 投递角色、Org Trail 权限、日志保留与防篡改
- [ ] 配置 GitHub Environment 必须审批、分支保护及 CODEOWNERS
- [ ] 对每个 Stack 在真实账号做 plan、审批、灰度 apply、回滚演练

## 明确未覆盖

CloudSSO/SSO、RAM 权限基线、成员账号工厂、CEN、NAT、云防火墙、Cloud Config、配置规则、Tag Policy、费用分账、跨账号日志归集、KMS CMK、异常告警、完整合规框架暂未实施。不能将此 Starter 视为已交付的企业 Production Landing Zone。

参考：
- 阿里云官方 Landing Zone Accelerator: https://github.com/aliyun/landing-zone-accelerator-on-alibaba-cloud
- OSS Backend: https://developer.hashicorp.com/terraform/language/backend/oss
- 阿里云 Terraform 认证: https://www.alibabacloud.com/help/en/terraform/terraform-authentication
