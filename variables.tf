variable "capacity_provider_asg_arn" {
  type        = string
  default     = null
  description = "ARN of Autoscaling Group for capacity provider"
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "Certificate ARN for the LB Listener"
}

variable "cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR block to allow access to the LB"
}

variable "cpu" {
  type        = number
  default     = 1024
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}

variable "create_lb" {
  type        = bool
  default     = false
  description = "Create Ingress load-balancer"
}


variable "desired_count" {
  type        = number
  default     = 1
  description = "Desired number of docker containers to run"
}


variable "ecs_cluster_id" {
  type        = string
  description = "Optional Cluster ID"
  default     = null
}

variable "ecs_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs assigned to ECS cluster"
  default     = null
}

variable "enable_container_insights" {
  type        = bool
  default     = true
  description = "Enable Cloudwatch Container Insights"
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  default     = true
  description = "Enable cross-zone load balancing of the (network) load balancer"
}

variable "environment" {
  type        = map(string)
  default     = {}
  description = "Environment variables defined in the docker container"
}

variable "health_check" {
  type = object({
    healthy_threshold   = number,
    interval            = number,
    path                = string,
    unhealthy_threshold = number
  })
  default = {
    healthy_threshold   = 3,
    interval            = 30,
    path                = null,
    unhealthy_threshold = 3
  }
  description = "Health check settings for the container"
}

variable "image" {
  type        = string
  description = "Docker image to run in the ECS cluster"
}

variable "image_firelens" {
  type        = string
  description = "Docker image of the firelens sidecar"
  default     = null
}


variable "kms_key_id" {
  type        = string
  default     = null
  description = "The custom KMS key ID used encryption of the Cloudwatch log group"
}

variable "load_balancer_deregistration_delay" {
  type        = number
  default     = 300
  description = "The amount of time before a target is deregistered when draining"
}

variable "load_balancer_eip" {
  type        = bool
  default     = false
  description = "Whether to create Elastic IPs for the load balancer"
}

variable "load_balancer_internal" {
  type        = bool
  default     = false
  description = "Set to true to create an internal load balancer"
}

variable "load_balancer_subnet_ids" {
  type        = list(string)
  default     = null
  description = "List of subnet IDs assigned to the LB"
}

variable "log_bucket" {
  type        = string
  default     = null
  description = "AWS Log bucket target"
}

variable "log_firehose" {
  type        = string
  default     = null
  description = "AWS Log firehose target"
}

variable "log_type" {
  type        = string
  default     = "awslogs"
  description = "AWS Log type"

  validation {
    condition     = contains(["awslogs", "s3", "firehose", "cloudwatch"], var.log_type)
    error_message = "Invalid input, options: \"awslogs\", \"s3\",\"firehose\",\"cloudwatch\"."
  }
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Fargate instance memory to provision (in MiB)"
}

variable "name" {
  type        = string
  description = "Name of the Fargate jobs"
}

variable "shortname" {
  type        = string
  description = "Name of the service in short, used if longer then 32"
  default     = null
}

variable "permissions_boundary" {
  type        = string
  description = "Permission boundary for the Role"
  default     = null
}

variable "port" {
  type        = number
  default     = 3000
  description = "Port exposed by the docker image to redirect traffic to"
}

variable "postfix" {
  type        = bool
  default     = false
  description = "Postfix the role and policy names with Role and Policy"
}

variable "protocol" {
  type        = string
  default     = null
  description = "The target protocol"

  validation {
    condition     = (var.protocol == null ? true : contains(["HTTP", "TCP"], var.protocol))
    error_message = "Allowed values for protocol are null, \"HTTP\" or \"TCP\"."
  }
}

variable "public_ip" {
  type        = bool
  default     = false
  description = "Assign a public ip to the service"
}

variable "readonly_root_filesystem" {
  type        = bool
  default     = true
  description = "When this parameter is true, the container is given read-only access to its root file system"
}

variable "region" {
  type        = string
  default     = null
  description = "The region this fargate cluster should reside in, defaults to the region used by the callee"
}

variable "role_policy" {
  type        = string
  description = "The Policy document for the role"
}

variable "role_prefix" {
  type        = string
  description = "Default prefix for the role"
  default     = null
}

variable "secrets" {
  type        = map(string)
  default     = {}
  description = "Map containing secrets to expose to the docker container"
}

variable "service_launch_type" {
  type        = string
  default     = "FARGATE"
  description = "The service launch type: either FARGATE or EC2"

  validation {
    condition     = contains(["FARGATE", "EC2"], var.service_launch_type)
    error_message = "Allowed values for service_launch_type are \"FARGATE\", or \"EC2\"."
  }
}

variable "ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  description = "SSL Policy for the LB Listener"
}

variable "subdomain" {
  type = object({
    name    = string,
    zone_id = string
  })
  default     = null
  description = "The DNS subdomain and zone ID for the LB"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}

variable "target_group_stickiness" {
  type        = bool
  default     = false
  description = "Whether to bind a client’s session to a specific instance within the target group"
}

variable "vpc_id" {
  type        = string
  description = "AWS vpc id"
}

variable "min_capacity" {
  type        = number
  default     = 1
  description = "Minimal Capacity for autoscalig"
}

variable "max_capacity" {
  type        = number
  default     = 5
  description = "Maximum Capacity for autoscalig"
}

variable "cpu_low_threshold" {
  default = 20
}
variable "cpu_high_threshold" {
  default = 80
}

variable "metric_low_threshold" {
  default = 20
}
variable "metric_high_threshold" {
  default = 80
}

variable "scale_metric_name" {
  default = 80
}

variable "scale_metric_namespace" {
  default = 80
}

variable "scale_up_cron" {
  type        = string
  description = "Cron schedule to scale up"
  default     = "cron(0 11 ? * MON-FRI *)"
}

variable "scale_down_cron" {
  type        = string
  description = "Cron schedule to scale down"
  default     = "cron(0 23 * * ? *)"
}

variable "scale_timezone" {
  type        = string
  description = "Timezone for scale up/down cron"
  default     = "europe/amsterdam"
}


variable "scale_down_min_capacity" {
  type        = number
  description = "Minimal capacity during down time"
  default     = 0
}

variable "scale_down_max_capacity" {
  type        = number
  description = "Maxium capacity during down time"
  default     = 0
}

variable "enable_deletion_protection" {
  default     = true
  type        = bool
  description = "Enable the delete protection for the lb"
}

variable "enable_autoscale_time" {
  default     = false
  type        = bool
  description = "Enable the autoscaling based on Cron settings"
}

variable "enable_autoscale_cpu" {
  default     = false
  type        = bool
  description = "Enable the autoscaling based on CPU"
}

variable "enable_autoscale_metric" {
  default     = false
  type        = bool
  description = "Enable the autoscaling based on Metric"
}


variable "disable_iam_tags" {
  type        = bool
  description = "Disable the IAM Role Tags, as blocked by a policy"
  default     = false
}


variable "repository_secret_arn" {
  description = "Repository Secret ARN"
  default     = null
  type        = string
}

variable "repository_secret_kms_key_arn" {
  description = "Repository Secret KMS Key ARN"
  default     = null
  type        = string
}

variable "image_loader" {
  type        = string
  default     = null
  description = "Docker image to run in the ECS cluster"
}

variable "keystore_secret" {
  type    = string
  default = null
}

variable "task_type" {
  type        = string
  default     = "single"
  description = "Task definition type"
}

variable "deployment_alarms_topics" {
  type        = list(string)
  default     = []
  description = "Enable deployment alarms and forward to these topics"
}


variable "deployment_circuit_breaker" {
  type        = bool
  default     = true
  description = "Enable deployment circuitbraker and roll-back"
}

variable "image_datadog" {
  type        = string
  default     = null
  description = "Datadog image"
}

variable "dd_api_key" {
  type        = string
  default     = null
  description = "Datadog api key"
}


