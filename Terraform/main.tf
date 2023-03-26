# Set up the AWS provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_lb" "contra" {
  name               = "contra-lb"
  internal           = false
  load_balancer_type = "application"
  subnets          = ["subnet-01e24930", "subnet-45a09408"]
  security_groups  = ["sg-4054134f"]
}

resource "aws_lb_target_group" "contra" {
  name_prefix        = "contra"
  port               = 3000
  protocol           = "TCP"
  target_type = "alb"
  vpc_id             = "vpc-aaad1dd7"
}

resource "aws_lb_target_group_attachment" "contra-attach" {
  target_group_arn = aws_lb_target_group.contra.arn
  target_id        = aws_lb.contra.id
  port             = 3000
}

# Set up the ECS cluster
resource "aws_ecs_cluster" "contra" {
  name = "contra-cluster"

  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }
}

# Set up the ECS task definition
resource "aws_ecs_task_definition" "contra-express" {
  family                   = "express-task"
  execution_role_arn       = "arn:aws:iam::079642970547:role/ecs-task-role"
  task_role_arn            = "arn:aws:iam::079642970547:role/ecs-task-role"
  container_definitions    = jsonencode([
    {
      name                    = "contra-container"
      image                   = "079642970547.dkr.ecr.us-east-1.amazonaws.com/express-demo:helloworld"
      memory      = 256
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol = "tcp"
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
  name            = "contra-service"
  cluster         = aws_ecs_cluster.contra.id
  task_definition = aws_ecs_task_definition.contra-express.arn
  depends_on = [
      aws_lb_target_group_attachment.contra-attach
  ]
  desired_count   = 1

  # Set up the service's network configuration
  network_configuration {
    assign_public_ip = true
    subnets          = ["subnet-01e24930", "subnet-45a09408"]
    security_groups  = ["sg-4054134f"]
  }

  # Set up the service's load balancer configuration
  load_balancer {
    target_group_arn = aws_lb_target_group.contra.arn
    container_name   = "contra-container"
    container_port   = 3000
  }
}


variable "image_tag" {}

variable "ecr_repo_url" {}

# Output the URL of the service
# output "service_url" {
#   value = aws_ecs_service.contra.service_url
# }






