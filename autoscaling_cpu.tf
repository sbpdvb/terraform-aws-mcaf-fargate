
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count               = var.enable_autoscale_cpu ? 1 : 0
  alarm_name          = "${var.name}-CPU-Utilization-High-${var.cpu_high_threshold}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.cpu_high_threshold

  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = aws_ecs_service.default.name
  }

  alarm_actions = [aws_appautoscaling_policy.app_up[count.index].arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  count               = var.enable_autoscale_cpu ? 1 : 0
  alarm_name          = "${var.name}-CPU-Utilization-Low-${var.cpu_low_threshold}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.cpu_low_threshold

  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = aws_ecs_service.default.name
  }

  alarm_actions = [aws_appautoscaling_policy.app_down[count.index].arn]
}

