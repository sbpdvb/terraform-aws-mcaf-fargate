[
     {
      "name": "aws-otel-collector",
      "image": "${image_opentel}",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/aws/ecs/otel-collector/${name}",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "ecs",
          "awslogs-create-group": "True"
        }
      },
      "healthCheck": {
        "command": [ "/healthcheck" ],
        "interval": 5,
        "timeout": 6,
        "retries": 5,
        "startPeriod": 1
      }
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
    "memoryReservation": 1024,
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

    ]
  }
]
