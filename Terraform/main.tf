# Set up the AWS provider
provider "aws" {
  region = "us-east-1"
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
  
  depends_on = [
    aws_ecs_cluster.contra
  ]
}

# Set up the ECS service
resource "aws_ecs_service" "contra" {
  name            = "contra-service"
  cluster         = aws_ecs_cluster.contra.id
  task_definition = aws_ecs_task_definition.contra-express.arn
  desired_count   = 1

  # Set up the service's network configuration
  network_configuration {
    # assign_public_ip = true
    subnets          = ["subnet-01e24930", "subnet-45a09408"]
    security_groups  = ["sg-4054134f"]
  }

}


variable "image_tag" {}

variable "ecr_repo_url" {}

# Output the URL of the service
# output "service_url" {
#   value = aws_ecs_service.contra.service_url
# }






