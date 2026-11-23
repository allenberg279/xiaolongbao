# 架构决策（ADR-0001）

**目标**：先建立 Terraform 可审查的基础 Cloud Landing Zone，保留未来 GitHub Actions 一键部署入口，当前不触发创建。

## 逻辑结构

```
Resource Directory management account (existing / bootstrap outside)
├── Security
├── SharedServices
├── Workloads
│   ├── dev
│   ├── test
│   └── prod
└── Sandbox

Network account (future): VPC -> private vSwitches
Log Archive account (future): private OSS -> optional ActionTrail
```

三个 Stack 需要**不同 Terraform State**；它们可先在单账号 Sandbox 中验证，正式使用时再拆分账号、角色、区域。

## 为什么不同时创建账号？

阿里云 Resource Directory 的开通存在企业资质与管理账号约束，多账号新建涉及财务、权限与企业治理审批。当前先创建 Folder，不自动开通账号或跨账号共享，以减少不可逆变更。

## 为什么不在代码提交时 Apply？

Landing Zone 更改的影响范围往往覆盖全组织，不等同普通应用发布。仅启用 lint/validate 自动化，云端变更采取人工触发，后续加 plan review、策略扫描、审批门禁和状态锁定。

## 安全边界

- GitHub 不保存凭证、State 或 Plan。
- OIDC 联邦登录 + 短期 RAM STS；需运营团队制定精确 Trust Policy。
- OSS 审计桶默认 private、阻止公开访问、AES256、版本控制，禁止非预期删除。
- ActionTrail 默认为关闭，以免未配置服务角色、错误日志投递导致假安全感。
- 真实环境需要对 ActionTrail/OSS 作持续有效性验证、保留规则和告警治理。
