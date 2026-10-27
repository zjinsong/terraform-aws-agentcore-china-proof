# 实测记录

测试日期：2026-10-27（Asia/Shanghai）

| 项目 | 结果 |
|---|---|
| Terraform CLI | 1.14.0 / Windows amd64 |
| AWS Provider | hashicorp/aws 6.70.0，官方签名校验通过 |
| Archive Provider | hashicorp/archive 2.8.1 |
| Region | cn-northwest-1（宁夏） |
| Artifact | S3 ZIP / PYTHON_3_12 / main.py |
| Endpoint override | 无；使用 Provider 默认端点解析 |
| terraform validate | Success! The configuration is valid. |
| terraform apply | 6 added, 0 changed, 0 destroyed |
| Runtime 创建耗时 | 4m1s |
| 实际调用 | HTTP 请求成功，返回预期 JSON |
| Runtime 服务端状态 | READY / version 1 |
| 第二次 terraform plan -detailed-exitcode | No changes. Your infrastructure matches the configuration. / 退出码 0 |

实际调用响应（无需模型或 API Key）：

```json
{
  "message": "Hello from AgentCore in Ningxia",
  "input": {
    "prompt": "Terraform China provider proof"
  }
}
```

本例证明 AWS Provider 6.70.0 能通过原生 `aws_bedrockagentcore_agent_runtime`
资源在宁夏部署并调用 ZIP Runtime。部署没有调用 boto3、Toolkit、CloudFormation
或 null_resource；boto3 只用于部署完成后的调用验证。

此结果不代表所有 AgentCore 组件或所有配置组合均已验证。
账号、完整资源 ARN、Terraform state 和原始 plan 不公开。
