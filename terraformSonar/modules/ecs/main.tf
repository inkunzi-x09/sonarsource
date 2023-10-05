resource "aws_ecs_task_definition" "sonarECS" {
  family                   = "hello-world-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  container_definitions = <<DEFINITION
[
  {
    "image": "registry.gitlab.com/architect-io/artifacts/nodejs-hello-world:latest",
    "cpu": 1024,
    "memory": 2048,
    "name": "hello-world-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
DEFINITION
}

resource "aws_security_group" "sonarTask" {
  name        = "sonar-task-security-group"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "sonarMainCluster" {
  name = "sonar-cluster"
}

resource "aws_ecs_service" "sonarECSService" {
  name            = "sonar-hello-world-service"
  cluster         = aws_ecs_cluster.sonarMainCluster.id
  task_definition = aws_ecs_task_definition.sonarECS.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.sonarTask.id]
    subnets         = var.private_subnet_ids
  }

  load_balancer {
    target_group_arn = var.sonarAlbTg_id
    container_name   = "hello-world-app"
    container_port   = 3000
  }

  depends_on = [var.sonarLbListener]
}