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
    "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
            "Name": "firehose",
            "region": "${region}",
            "delivery_stream": "${log_firehose}"
        }
    },
    "memoryReservation": 1024,
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
