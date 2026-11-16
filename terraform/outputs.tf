output "worker_url" {
  description = "HTTPS endpoint for the worker service."
  value       = "https://${aws_lb.worker.dns_name}"
}

output "ecs_cluster_name" {
  description = "ECS cluster running the worker."
  value       = aws_ecs_cluster.worker.name
}

output "ecs_service_name" {
  description = "ECS service managing the worker tasks."
  value       = aws_ecs_service.worker.name
}

output "worker_log_group" {
  description = "CloudWatch log group for worker container logs."
  value       = aws_cloudwatch_log_group.worker.name
}
