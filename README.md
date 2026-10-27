# Terraform AWS AgentCore China ZIP proof

用 HashiCorp AWS Provider **6.70.0**，在中国宁夏 **cn-northwest-1** 原生部署 AgentCore Runtime。
不使用 ECR、Docker、Toolkit、自定义 Provider 或自定义服务端点。

## 部署

准备 Terraform >= 1.10、AWS China 凭证、Python 和 boto3。
部署身份需要管理本示例的 IAM Role、S3 Bucket、AgentCore Runtime，以及 iam:PassRole 权限。

```powershell
terraform init
terraform validate
terraform plan -out=proof.tfplan
terraform apply proof.tfplan
python invoke.py
terraform plan -detailed-exitcode
```

预期调用响应包含 `Hello from AgentCore in Ningxia`。
最后一条 plan 应返回退出码 0，表示无配置漂移。

`main.tf` 创建私有 S3 Bucket、上传本地 ZIP、创建 IAM Role 和 AgentCore Runtime。
`agent/main.py` 用 Python 标准库提供 `/ping` 和 `/invocations` HTTP 接口；不调用模型，不需要模型权限或密钥。
`invoke.py` 仅负责调用部署后的 Runtime；部署本身完全由 Terraform AWS Provider 完成。

Provider 未设置 `endpoints`。不要在验证环境配置 `AWS_ENDPOINT_URL` 等端点覆盖，否则不能用于证明默认端点解析有效。

## 清理

```powershell
terraform destroy
```

示例 Bucket 设置 `force_destroy = true`，destroy 会删除该示例 Bucket 内的对象。
不要向示例 Bucket 写入其他业务数据。CloudWatch 自动创建的运行日志可能需要另外清理。

State、计划文件、ZIP、凭证不提交到仓库。此目录与 CloudOps 的代码和 Terraform state 独立。

## 验证记录

实际验证结果见 [VERIFICATION.md](VERIFICATION.md)。
