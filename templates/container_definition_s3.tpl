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
         		"Name": "s3",
            "region": "${region}",
            "bucket": "${log_bucket}",
            "total_file_size": "1M",
            "upload_timeout": "1m",
            "use_put_object": "On",
            "retry_limit": "2"            
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
