variable "aws_region" {
  description = "AWS region containing the worker infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name used in resource names and tags."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "environment may contain only lowercase letters, numbers, and hyphens."
  }
}

variable "worker_image" {
  description = "Published worker container image URI."
  type        = string

  validation {
    condition     = length(trimspace(var.worker_image)) > 0
    error_message = "worker_image must be a non-empty image URI."
  }
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN for the HTTPS load balancer listener."
  type        = string

  validation {
    condition     = can(regex("^arn:[^:]+:acm:", var.acm_certificate_arn))
    error_message = "acm_certificate_arn must be an ACM certificate ARN."
  }
}

variable "allowed_ingress_cidrs" {
  description = "CIDR ranges allowed to reach the worker through the load balancer."
  type        = list(string)

  validation {
    condition = length(var.allowed_ingress_cidrs) > 0 && alltrue([
      for cidr in var.allowed_ingress_cidrs : can(cidrnetmask(cidr)) && cidr != "0.0.0.0/0"
    ])
    error_message = "Set trusted IPv4 caller CIDRs and do not expose the worker to all networks."
  }
}

variable "worker_port" {
  description = "HTTP port exposed by the worker container."
  type        = number
  default     = 3003

  validation {
    condition     = var.worker_port > 0 && var.worker_port < 65536
    error_message = "worker_port must be a valid TCP port."
  }
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of worker tasks to keep running."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 1
    error_message = "desired_count must be at least one."
  }
}
