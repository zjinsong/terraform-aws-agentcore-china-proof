"""Run after terraform apply: python invoke.py"""
import json
import subprocess
import uuid
import boto3

arn = subprocess.check_output(['terraform', 'output', '-raw', 'runtime_arn'], text=True).strip()
response = boto3.client('bedrock-agentcore', region_name='cn-northwest-1').invoke_agent_runtime(
    agentRuntimeArn=arn,
    runtimeSessionId=str(uuid.uuid4()),
    contentType='application/json',
    payload=json.dumps({'prompt': 'Terraform China provider proof'}).encode(),
)
body = b''.join(response['response']).decode()
print(body)
assert 'Hello from AgentCore in Ningxia' in body
