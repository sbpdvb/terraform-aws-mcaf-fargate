[
    {
      "essential": false,
      "image": "${image_loader}",
      "name": "config_loader",
      "cpu"                   : 0,
      "environment"           : [],
      "mountPoints"           : [],
      "portMappings"          : [],
      "user"                  : "0",
      "volumesFrom": [],
      "environment": ${environment},
      "secrets": ${secrets},
      "readonlyRootFilesystem": ${readonlyRootFilesystem},
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
					  "awslogs-region": "${region}",
            "awslogs-group": "/aws/ecs/containerinsights/${name}",
					  "awslogs-create-group": "true",
					  "awslogs-stream-prefix": "config_loader"
        }
     },
      "mountPoints" : [
        {
         "ContainerPath": "/config",
          "SourceVolume": "config"
        }
       ],
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
    "dependsOn": [
      {
        "containerName": "config_loader",
        "condition": "SUCCESS"
      }
    ],
    "volumesFrom": [
    ],
    "mountPoints" : [
        {
         "ContainerPath": "/config",
          "SourceVolume": "config"
      }
    ]
  }
]
