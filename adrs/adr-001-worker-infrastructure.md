# ADR 001: Worker Infrastructure

- **Status**: Accepted
- **Date**: 2026-11-15

## Context

The Salud Activa project contains a standalone appointment workflow service that
listens on port `3003` and exposes `GET /health`. The worker repository currently
holds deployment configuration; application images are produced separately.

## Decision

- Use Docker Compose to run one prebuilt worker image locally.
- Use Terraform to run the image as an ECS Fargate service behind an HTTPS
  Application Load Balancer.
- Require an existing ACM certificate and an explicit allowlist of caller CIDRs.
- Keep MongoDB and RabbitMQ out of this worker stack; the MVP 2 appointments
  service owns those dependencies.

## Consequences

- The application pipeline must publish a worker image before Compose or Terraform
  can start the service.
- The worker remains reachable through the load balancer without exposing its task
  port directly.
- The AWS deployment needs an ACM certificate in the selected region and network
  access limited to trusted callers.
