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

    ]
  }
]
