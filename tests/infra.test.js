const { describe, test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');

function read(relativePath) {
  return fs.readFileSync(path.join(root, relativePath), 'utf8');
}

describe('Worker infrastructure configuration', () => {
  test('Compose runs only the worker on its documented local port and health endpoint', () => {
    const compose = read('docker-compose.yml');

    assert.match(compose, /services:\s+worker:/);
    assert.match(compose, /WORKER_IMAGE/);
    assert.match(compose, /127\.0\.0\.1:\$\{WORKER_PORT:-3003\}:3003/);
    assert.match(compose, /\/health/);
    assert.doesNotMatch(compose, /^\s+(mongodb|rabbitmq|api-gateway):/m);
  });

  test('Terraform deploys the worker to Fargate behind HTTPS and checks /health', () => {
    const terraform = read('terraform/main.tf');
    const variables = read('terraform/variables.tf');

    assert.match(terraform, /resource "aws_ecs_cluster" "worker"/);
    assert.match(terraform, /resource "aws_ecs_service" "worker"/);
    assert.match(terraform, /requires_compatibilities\s+= \["FARGATE"\]/);
    assert.match(terraform, /resource "aws_lb_listener" "https"/);
    assert.match(terraform, /certificate_arn\s+= var\.acm_certificate_arn/);
    assert.match(terraform, /path\s+= "\/health"/);
    assert.match(terraform, /security_groups\s+= \[aws_security_group\.load_balancer\.id\]/);
    assert.match(variables, /allowed_ingress_cidrs/);
    assert.match(variables, /acm_certificate_arn/);
  });

  test('Example Terraform variables contain placeholders, not real secrets or open ingress', () => {
    const example = read('terraform/terraform.tfvars.example');

    assert.match(example, /replace-with-real-certificate-id/);
    assert.match(example, /203\.0\.113\.0\/24/);
    assert.doesNotMatch(example, /0\.0\.0\.0\/0/);
  });
});
