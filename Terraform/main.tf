# Set up the AWS provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "stater-terraform-bucket"
    key    = "remote/ecs/state"
    region = "us-east-1"
  }
}

# Set up the ECS cluster
resource "aws_ecs_cluster" "contra" {
  name = "contra-cluster"

}

# Set up the ECS task definition
resource "aws_ecs_task_definition" "contra-express" {
  family             = "express-task"
  execution_role_arn = "arn:aws:iam::079642970547:role/ecs-task-role"
  task_role_arn      = "arn:aws:iam::079642970547:role/ecs-task-role"
  container_definitions = jsonencode([
    {
      name   = "contra-container"
      image  = "079642970547.dkr.ecr.us-east-1.amazonaws.com/express-demo:helloworld"
      memory = 256
      cpu = 256
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"

}

# Set up the ECS service
resource "aws_ecs_service" "contra" {
  name            = "contra-ecs-service"
  cluster         = aws_ecs_cluster.contra.id
  task_definition = aws_ecs_task_definition.contra-express.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Set up the service's network configuration
  network_configuration {
    assign_public_ip = true
    subnets         = ["subnet-01e24930", "subnet-45a09408"]
    security_groups = ["sg-0e028ca84fbaf152a"]
  }

}

variable "image_tag" {}



