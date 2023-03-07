[
  {
      "essential": true,
      "image": "${image_firelens}",
      "name": "log_router",
      "firelensConfiguration": {
          "type": "fluentbit"
      },
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${log_group}",
              "awslogs-region": "${region}",
              "awslogs-create-group": "true",
              "awslogs-stream-prefix": "firelens"
          }
      },
      "cpu"                   : 0,
      "environment"           : [],
      "mountPoints"           : [],
      "portMappings"          : [],
      "user"                  : "0",
      "volumesFrom"           : [] ,
      "environment": ${environment},
      "secrets": ${secrets},
      "memoryReservation": 50
  },
  {
    "essential": true,
    "name": "app-${name}",
    "image": "${image}",
    "cpu": ${cpu},
    "memory": ${memory},
    "networkMode": "awsvpc",
    "environment": ${environment},
    "readonlyRootFilesystem": ${readonlyRootFilesystem},
    "secrets": ${secrets},
    "repositoryCredentials": {
            "credentialsParameter": "${repository_secret}"
    },
    "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
            "Name": "cloudwatch",
					  "region": "${region}",
            "log_key": "log",
            "log_group_name": "/aws/ecs/containerinsights/$(ecs_cluster)/application",
					  "auto_create_group": "true",
					  "log_stream_name": "$(ecs_task_id)",
            "log_retention_days": "30"
        }
    },
    "memoryReservation": ${memoryReservation},
    "portMappings": [
      {
        "containerPort": ${port},
        "hostPort": ${port}
      }
    ],
    "volumesFrom": [],
    "mountPoints": []
  }
]
