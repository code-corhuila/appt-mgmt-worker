# appt-mgmt-worker

> Asynchronous jobs and background processing

Part of the **LMS Library** distributed system — team `lms-library`, Grupo 2.
Governance and documentation live in [`library-docs`](https://github.com/code-corhuila/library-docs).

## Branching

Three permanent branches. **None of them accepts a direct commit** — you enter through a child
branch and leave through a Pull Request.

```
develop  <--PR--  feat/... fix/... chore/...
qa       <--PR--  qa/...
main     <--PR--  release/...  hotfix/...
```

Promotion happens **by re-application** (`git cherry-pick -x`), never by merging one permanent
branch into another: `merge develop -> qa` and `merge qa -> main` do not exist in this model.

`main` requires **1 approval from `ariel5253`**. On `develop` and `qa` the team sets its own review
rule.

Full policy: `00-governance/branching-policy.md` in `library-docs`.

## Worker infrastructure

This repository contains the deployment configuration for the standalone appointment
workflow worker described in the Salud Activa project: an HTTP service on port `3003`
with a `GET /health` endpoint. It does not provision MongoDB or RabbitMQ; those belong
to the separate MVP 2 appointments service.

The worker image must be built and published by the worker application pipeline. Set
`WORKER_IMAGE` to that image before starting the local Compose service:

```powershell
# From the Salud Activa project root; the workflow service provides the worker image.
docker build -t appt-mgmt-worker:local c2-release/appt-mgmt-workflow

# From this repository.
Copy-Item .env.example .env
# Set WORKER_IMAGE in .env to an image available to Docker.
docker compose up -d
docker compose ps
```

For AWS, configure `terraform/terraform.tfvars` using
`terraform/terraform.tfvars.example`. Set an existing ACM certificate ARN and restrict
`allowed_ingress_cidrs` to the API gateway or other trusted callers before applying:

```powershell
Set-Location terraform
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

The ECS service runs in Fargate behind an HTTPS Application Load Balancer. Its task
security group accepts worker traffic only from that load balancer; the load balancer
health-checks `/health`. Terraform state and credentials must remain outside source
control. `terraform apply` creates billable AWS resources; review the plan and expected
costs before approving it.
