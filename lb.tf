resource "random_id" "lb_name" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    name = var.name
  }

  byte_length = 4
}

locals {
  lb_hostname         = var.create_lb && local.load_balancer != null ? aws_lb.default[0].dns_name : null
  http_listener_arn   = var.create_lb && local.load_balancer != null && var.protocol != "TCP" ? aws_lb_listener.http[0].arn : null
  https_listener_arn  = var.create_lb && local.load_balancer != null && var.protocol != "TCP" ? aws_lb_listener.https[0].arn : null
  tcp_listener_arn    = var.create_lb && local.load_balancer != null && var.protocol == "TCP" ? aws_lb_listener.tcp[0].arn : null
  load_balancer_count = var.create_lb && local.load_balancer != null ? 1 : 0
  eip_subnets         = var.create_lb && var.load_balancer_eip ? var.load_balancer_subnet_ids : []
  lb_log_s3_bucket    = var.create_lb && var.load_balancer_log_s3 != null ? var.load_balancer_log_s3 : null

  lb_shortname = length(var.name) > 32 ? "${substr(var.name, 0, 27)}-${substr(random_id.lb_name.hex, 0, 4)}" : var.name

  target_group_arn = var.create_lb && local.load_balancer == null ? null : (
    length(aws_lb_target_group.default) > 0 ? aws_lb_target_group.default[0].arn : null
  )
}

resource "aws_security_group" "lb" {
  count       = var.create_lb && var.protocol != "TCP" ? local.load_balancer_count : 0
  name        = "${var.name}-lb"
  description = "Controls access to the LB"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    description = "HTTP ingress"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.cidr_blocks #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  }

  ingress {
    description = "HTTPS ingress"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.cidr_blocks #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  }

  egress {
    description = "Public egress"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0

    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  }
}

resource "aws_eip" "lb" {
  count = length(local.eip_subnets)

  #checkov:skip=CKV2_AWS_19:Ensure that all EIP addresses allocated to a VPC are attached to EC2 instances
  vpc  = true
  tags = var.tags
}

resource "aws_lb" "default" {
  # This is done, but checkov doens't detect
  #checkov:skip=CKV2_AWS_20:Ensure that ALB redirects HTTP requests into HTTPS ones
  #checkov:skip=CKV_AWS_91:Ensure the ELBv2 (Application/Network) has access logging enabled

  count                            = local.load_balancer_count
  name                             = local.lb_shortname
  drop_invalid_header_fields       = var.protocol != "TCP" ? true : null
  internal                         = var.load_balancer_internal #tfsec:ignore:AWS005
  load_balancer_type               = var.protocol == "TCP" ? "network" : "application"
  enable_cross_zone_load_balancing = var.protocol == "TCP" ? var.enable_cross_zone_load_balancing : false
  subnets                          = var.load_balancer_eip ? null : var.load_balancer_subnet_ids
  security_groups                  = var.protocol != "TCP" ? [aws_security_group.lb[0].id] : null
  enable_deletion_protection       = var.enable_deletion_protection
  tags                             = var.tags

  dynamic "subnet_mapping" {
    for_each = [for subnet_id in local.eip_subnets : {
      subnet_id     = subnet_id
      allocation_id = aws_eip.lb[index(local.eip_subnets, subnet_id)].id
    }]

    content {
      subnet_id     = subnet_mapping.value.subnet_id
      allocation_id = subnet_mapping.value.allocation_id
    }
  }

  dynamic "access_logs" {
    for_each = local.lb_log_s3_bucket != null ? [1] : []
      content {
        bucket  = local.lb_log_s3_bucket
        enabled = local.lb_log_s3_bucket != null ? true : false
        prefix  = local.lb_shortname
    }
  }

  timeouts {
    create = "20m"
  }
}

resource "aws_lb_listener" "http" {
  count             = var.protocol == "TCP" ? 0 : local.load_balancer_count
  load_balancer_arn = aws_lb.default[count.index].id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = local.application_fqdn
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "default" {
  count                = local.load_balancer_count
  name                 = local.lb_shortname
  deregistration_delay = var.load_balancer_deregistration_delay
  port                 = var.port
  protocol             = var.protocol
  target_type          = "ip"
  vpc_id               = var.vpc_id
  tags                 = var.tags

  dynamic "health_check" {
    for_each = length(var.health_check) > 0 ? [1] : []

    content {
      interval            = var.health_check.interval
      timeout             = var.health_check.timeout
      protocol            = var.health_check.protocol
      path                = var.health_check.path
      port                = var.health_check.port
      matcher             = var.health_check.matcher
      healthy_threshold   = var.health_check.healthy_threshold
      unhealthy_threshold = var.health_check.unhealthy_threshold
    }
  }

  stickiness {
    enabled = var.target_group_stickiness
    type    = var.protocol == "HTTP" ? "lb_cookie" : "source_ip"
  }
}

resource "aws_lb_listener" "https" {
  count             = var.create_lb && var.protocol == "TCP" ? 0 : local.load_balancer_count
  load_balancer_arn = aws_lb.default[0].id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = local.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[0].id
  }
}

resource "aws_lb_listener" "tcp" {
  count             = var.create_lb && var.protocol == "TCP" ? 1 : 0
  load_balancer_arn = aws_lb.default[0].id
  port              = var.port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[0].id
  }
}
