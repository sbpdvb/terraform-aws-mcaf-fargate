
# Scales service back up to preferred running capacity defined by the
# `ecs_autoscale_min_instances` and `ecs_autoscale_max_instances` variables
resource "aws_appautoscaling_scheduled_action" "app_autoscale_time_up" {
  count = var.enable_autoscale_time ? 1 : 0
  name  = "${var.name}-app-autoscale-time-up"

  service_namespace  = aws_appautoscaling_target.ecs_target[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[count.index].scalable_dimension
  schedule           = var.scale_up_cron

  scalable_target_action {
    min_capacity = aws_appautoscaling_target.ecs_target[count.index].min_capacity
    max_capacity = aws_appautoscaling_target.ecs_target[count.index].max_capacity
  }
}

# Scales service down to capacity defined by the
# `scale_down_min_capacity` and `scale_down_max_capacity` variables.
resource "aws_appautoscaling_scheduled_action" "app_autoscale_time_down" {
  count = var.enable_autoscale_time ? 1 : 0
  name  = "${var.name}app-autoscale-time-down"

  service_namespace  = aws_appautoscaling_target.ecs_target[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[count.index].scalable_dimension
  schedule           = var.scale_down_cron

  scalable_target_action {
    min_capacity = var.scale_down_min_capacity
    max_capacity = var.scale_down_max_capacity
  }
}