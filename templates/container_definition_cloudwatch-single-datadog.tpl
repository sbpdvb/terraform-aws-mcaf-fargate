[

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
    "memoryReservation": ${memoryReservation},
    "portMappings": [
      {
        "containerPort": ${port},
        "hostPort": ${port}
      }
    ],
     "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
					  "awslogs-region": "${region}",
            "awslogs-group": "/aws/ecs/containerinsights/${name}",
					  "awslogs-create-group": "true",
					  "awslogs-stream-prefix": "app-${name}"
        }
     },
    "volumesFrom": [
    ],
    "mountPoints" : [
    ],
    "dockerLabels": {
            "com.datadoghq.ad.instances": "[{\"host\": \"%%host%%\", \"port\": 443}]",
            "com.datadoghq.ad.check_names": "[\"app-${name}\"]",
            "com.datadoghq.ad.init_configs": "[{}]"
    }
  },
  {
        "name": "datadog-agent",
        "image": "${image_datadog}",
        "environment": [
        {
            "name": "DD_API_KEY",
            "value": "${dd_api_key}"
        },
        {
            "name": "ECS_FARGATE",
            "value": "true"
        }
        ]
    }
]
