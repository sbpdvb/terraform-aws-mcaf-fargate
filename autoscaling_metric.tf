
resource "aws_cloudwatch_metric_alarm" "metric_utilization_high" {
  count               = var.enable_autoscale_metric ? 1 : 0
  alarm_name          = "${var.name}-${var.scale_metric_name}-${var.metric_high_threshold}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.scale_metric_name
  namespace           = var.scale_metric_namespace
  period              = "60"
  statistic           = "Average"
  threshold           = var.metric_high_threshold

  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = aws_ecs_service.default.name
  }

  alarm_actions = [aws_appautoscaling_policy.app_up[count.index].arn]
}

resource "aws_cloudwatch_metric_alarm" "metric_utilization_low" {
  count               = var.enable_autoscale_metric ? 1 : 0
  alarm_name          = "${var.name}-${var.scale_metric_name}-Low-${var.metric_low_threshold}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = var.scale_metric_name
  namespace           = var.scale_metric_namespace
  period              = "60"
  statistic           = "Average"
  threshold           = var.metric_low_threshold

  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = aws_ecs_service.default.name
  }

  alarm_actions = [aws_appautoscaling_policy.app_down[count.index].arn]
}

