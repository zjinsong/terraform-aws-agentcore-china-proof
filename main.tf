terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.70.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

provider "aws" {
  region = "cn-northwest-1"
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_s3_bucket" "code" {
  bucket_prefix = "tf-agentcore-cn-proof-"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "code" {
  bucket                  = aws_s3_bucket.code.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "archive_file" "agent" {
  type        = "zip"
  source_dir  = "${path.module}/agent"
  output_path = "${path.module}/build/agent.zip"
}

resource "aws_s3_object" "code" {
  bucket = aws_s3_bucket.code.id
  key    = "agent-${data.archive_file.agent.output_sha256}.zip"
  source = data.archive_file.agent.output_path
  etag   = data.archive_file.agent.output_md5
}

resource "aws_iam_role" "runtime" {
  name_prefix = "tf-agentcore-cn-proof-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "bedrock-agentcore.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = { StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id } }
    }]
  })
}

resource "aws_iam_role_policy" "runtime" {
  role = aws_iam_role.runtime.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["s3:GetObject"], Resource = "${aws_s3_bucket.code.arn}/*" },
      { Effect = "Allow", Action = ["s3:ListBucket"], Resource = aws_s3_bucket.code.arn },
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"], Resource = "arn:${data.aws_partition.current.partition}:logs:cn-northwest-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/*" }
    ]
  })
}

resource "aws_bedrockagentcore_agent_runtime" "proof" {
  agent_runtime_name = "terraform_cn_zip_proof"
  role_arn           = aws_iam_role.runtime.arn
  description        = "AWS provider 6.70.0 ZIP deployment proof in Ningxia"
  agent_runtime_artifact {
    code_configuration {
      entry_point = ["main.py"]
      runtime     = "PYTHON_3_12"
      code {
        s3 {
          bucket = aws_s3_bucket.code.id
          prefix = aws_s3_object.code.key
        }
      }
    }
  }
  network_configuration {
    network_mode = "PUBLIC"
  }
  depends_on = [aws_iam_role_policy.runtime]
}

output "runtime_arn" {
  value = aws_bedrockagentcore_agent_runtime.proof.agent_runtime_arn
}
output "runtime_id" {
  value = aws_bedrockagentcore_agent_runtime.proof.agent_runtime_id
}
