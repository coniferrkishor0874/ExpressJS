# Set up the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Set up the ECS cluster
resource "aws_ecs_cluster" "contra" {
  name = "contra-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Set up the ECS task definition
resource "aws_ecs_task_definition" "contra-express" {
  family                   = "express-task"
#   execution_role_arn       = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
  container_definitions    = jsonencode([
    {
      name                    = "contra-container"
      image                   = "079642970547.dkr.ecr.us-east-1.amazonaws.com/express-demo:helloworld"
      memory_reservation      = 256
      port_mappings = [
        {
          container_port = 3000
          host_port      = 3000
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
  task_definition = aws_ecs_task_definition.contra.arn
  desired_count   = 1

  # Set up the service's network configuration
  network_configuration {
    assign_public_ip = true
    subnets          = ["subnet-01e24930", "subnet-45a09408"]
    security_groups  = ["sg-4054134f"]
  }

  # Set up the service's load balancer configuration
  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/contra-tg/abcdef1234567890"
    container_name   = "contra-container"
    container_port   = 3000
  }
}



# Output the URL of the service
output "service_url" {
  value = "http://${aws_ecs_service.contra.load_balancers[0].dns_name}:3000"
}







