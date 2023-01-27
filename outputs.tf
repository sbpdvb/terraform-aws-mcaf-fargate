output "name" {
  value       = var.name
  description = "Name of the fargate deployment"
}

# output "cluster_arn" {
#   value       = try(aws_ecs_cluster.default[0].arn, null)
#   description = "The ARN of the ECS cluster"
# }

# output "cluster_id" {
#   description = "The Id of the ECS cluster"
#   value       = try(aws_ecs_cluster.default[0].id, null)
# }

# output "cluster_name" {
#   description = "The name of the ECS cluster"
#   value       = try(aws_ecs_cluster.default[0].name, null)
# }


output "fqdn" {
  value       = local.application_fqdn
  description = "FQDN of the route53 endpoint"
}

output "hostname" {
  value       = local.lb_hostname
  description = "Hostname of the Application load balancer"
}

output "http_listener_arn" {
  value       = local.http_listener_arn
  description = "The ARN of the HTTP listener"
}

output "https_listener_arn" {
  value       = local.https_listener_arn
  description = "The ARN of the HTTPS listener"
}

output "load_balancer_eips" {
  value       = try(aws_eip.lb.*.public_ip, null)
  description = "The Elastic IPs of the load balancer"
}

output "security_group_id" {
  value       = aws_security_group.ecs.id
  description = "Security group ID of the ECS task"
}

output "target_group_arn" {
  value       = local.target_group_arn
  description = "The ARN of the Target Group"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.default.arn
  description = "ARN of the task definition"
}

output "task_execution_role_arn" {
  value       = module.task_execution_role.arn
  description = "ARN of the execution role"
}

output "tcp_listener_arn" {
  value       = local.tcp_listener_arn
  description = "The ARN of the TCP listener"
}
