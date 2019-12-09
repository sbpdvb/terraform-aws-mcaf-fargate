output "name" {
  value       = var.name
  description = "Name of the fargate deployment"
}

output "fqdn" {
  value       = local.application_fqdn
  description = "FQDN of the route53 endpoint"
}

output "hostname" {
  value       = local.alb_hostname
  description = "Hostname of the Application Loadbalancer"
}

output "http_listener_arn" {
  value       = local.http_listener_arn
  description = "The ARN of the HTTP listener"
}

output "https_listener_arn" {
  value       = local.https_listener_arn
  description = "The ARN of the HTTPS listener"
}

output "security_group_id" {
  value       = aws_security_group.ecs.id
  description = "Security group ID of the ECS task"
}

output "target_group_arn" {
  value       = local.target_group_arn
  description = "The ARN of the Target Group"
}

output "task_execution_role_arn" {
  value       = module.task_execution_role.arn
  description = "ARN of the execution role"
}
