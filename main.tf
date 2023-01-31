locals {
  # disable cluster creation in mode
  #ecs_cluster_id   = var.ecs_cluster_id != null ? var.ecs_cluster_id : try(aws_ecs_cluster.default[0].id, null)
  ecs_cluster_id   = var.ecs_cluster_id
  ecs_cluster_name = split("/", local.ecs_cluster_id)[1]

  load_balancer = var.load_balancer_subnet_ids != null ? { create : true } : null
  region        = var.region != null ? var.region : data.aws_region.current.name

  environment = [
    for k, v in var.environment :
    {
      name  = k
      value = v
    }
  ]

  secrets = [
    for k, v in var.secrets :
    {
      name      = k
      valueFrom = v
    }
  ]



}

data "aws_region" "current" {}

module "task_execution_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.2"
  name                  = join("-", compact([var.role_prefix, "taskex", var.name]))
  create_policy         = true
  principal_type        = "Service"
  principal_identifiers = ["ecs-tasks.amazonaws.com"]
  role_policy           = var.role_policy
  postfix               = var.postfix
  permissions_boundary  = var.permissions_boundary
  tags                  = var.disable_iam_tags ? null : var.tags
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = module.task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_policy" "log_s3_policy" {
  count       = var.log_bucket != null ? 1 : 0
  name        = join("-", compact([var.role_prefix, "LogWriteS3", var.name]))
  description = "permissions to write log to s3 bucket"


  policy = jsonencode({
    #tfsec:ignore:aws-iam-no-policy-wildcards

    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:putObject"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.log_bucket}/*"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "log_s3_policy_attach" {
  count = var.log_bucket != null ? 1 : 0

  role       = module.task_execution_role.id
  policy_arn = aws_iam_policy.log_s3_policy[0].arn
}

resource "aws_iam_policy" "secrets_policy" {
  count       = length(var.secrets) > 0 ? 1 : 0
  name        = join("-", compact([var.role_prefix, "Secrets", var.name]))
  description = "permissions to read secrets"

  policy = jsonencode({

    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue"
        ],
        Effect   = "Allow",
        Resource = values(var.secrets)
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_policy_attach" {
  count = length(var.secrets) > 0 ? 1 : 0

  role       = module.task_execution_role.id
  policy_arn = aws_iam_policy.secrets_policy[0].arn
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html
resource "aws_iam_policy" "repository_creds_policy" {
  count       = var.repository_secret_arn != null ? 1 : 0
  name        = join("-", compact([var.role_prefix, "ReadSecret", var.name]))
  description = "permissions to read secret for repository"

  policy = jsonencode({

    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue"
        ],
        Effect = "Allow",
        Resource = [
          var.repository_secret_arn,
          var.repository_secret_kms_key_arn
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "repository_creds_policy_attach" {
  count = var.repository_secret_arn != null ? 1 : 0

  role       = module.task_execution_role.id
  policy_arn = aws_iam_policy.repository_creds_policy[0].arn
}



module "task_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.2"
  name                  = join("-", compact([var.role_prefix, "task", var.name]))
  create_policy         = true
  principal_type        = "Service"
  principal_identifiers = ["ecs-tasks.amazonaws.com"]
  role_policy           = var.role_policy
  postfix               = var.postfix
  permissions_boundary  = var.permissions_boundary
  tags                  = var.disable_iam_tags ? null : var.tags
}



resource "aws_iam_role_policy_attachment" "task_log_s3_policy_attach" {
  count = var.log_bucket != null ? 1 : 0

  role       = module.task_role.id
  policy_arn = aws_iam_policy.log_s3_policy[0].arn
}


resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${var.name}"
  retention_in_days = 30
  kms_key_id        = var.kms_key_id
  tags              = var.tags
}

resource "aws_ecs_task_definition" "default" {
  family                   = var.name
  execution_role_arn       = module.task_execution_role.arn
  task_role_arn            = module.task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = [var.service_launch_type]
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = templatefile("${path.module}/templates/container_definition_${var.log_type}-${var.task_type}.tpl", {
    name                   = var.name
    image                  = var.image
    port                   = var.port
    cpu                    = var.cpu
    memory                 = var.memory
    log_group              = aws_cloudwatch_log_group.default.name
    environment            = jsonencode(local.environment)
    secrets                = jsonencode(local.secrets)
    readonlyRootFilesystem = var.readonly_root_filesystem
    region                 = local.region
    image_firelens         = var.image_firelens
    log_firehose           = var.log_firehose
    log_bucket             = var.log_bucket
    image_loader           = var.image_loader
  })

  volume {
    name = "config"
    # host_path = "/config"
  }

  tags = var.tags
}

resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs"
  description = "Allow access to and from the ECS cluster"
  vpc_id      = var.vpc_id
  tags        = var.tags

  dynamic "ingress" {
    for_each = aws_lb.default

    content {
      description     = "Allow access from the ECS cluster"
      protocol        = "tcp"
      from_port       = var.port
      to_port         = var.port
      security_groups = var.protocol != "TCP" ? [aws_security_group.lb.0.id] : null
      cidr_blocks     = var.protocol == "TCP" ? var.cidr_blocks : null
    }
  }

  egress {
    description = "Allow all outgoing traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  }

  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_ecs_service" "default" {
  name            = var.name
  cluster         = local.ecs_cluster_id
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = var.desired_count
  launch_type     = var.service_launch_type
  propagate_tags  = "TASK_DEFINITION"

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.ecs_subnet_ids
    assign_public_ip = var.service_launch_type == "FARGATE" ? var.public_ip : false
  }

  dynamic "load_balancer" {
    for_each = var.create_lb ? aws_lb.default : []
    content {
      target_group_arn = aws_lb_target_group.default.0.id
      container_name   = "app-${var.name}"
      container_port   = var.port
    }
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge({ "Name" : var.name }, var.tags)
}
