# disable cluster creation in module as this leads to dependency loop

# resource "aws_ecs_cluster" "default" {
#   count = var.capacity_provider_asg_arn == null && var.ecs_cluster_id == null ? 1 : 0
#   name  = var.name
#   tags  = var.tags

#   setting {
#     name  = "containerInsights"
#     value = var.enable_container_insights ? "enabled" : "disabled"
#   }
# }

# resource "aws_ecs_capacity_provider" "default" {
#   count = var.capacity_provider_asg_arn != null && var.ecs_cluster_id == null ? 1 : 0
#   name  = "${var.name}-capacity-provider"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn         = var.capacity_provider_asg_arn
#     managed_termination_protection = "DISABLED"

#     managed_scaling {
#       instance_warmup_period = 60
#       status                 = "ENABLED"
#       target_capacity        = 100
#     }
#   }
# }

# resource "aws_ecs_cluster_capacity_providers" "default" {
#   count              = var.capacity_provider_asg_arn != null && var.ecs_cluster_id == null ? 1 : 0
#   capacity_providers = [aws_ecs_capacity_provider.default[*].name]
#   cluster_name       = aws_ecs_cluster.default[0].name

#   default_capacity_provider_strategy {
#     base              = 1
#     weight            = 100
#     capacity_provider = aws_ecs_capacity_provider.default[*].name
#   }
# }