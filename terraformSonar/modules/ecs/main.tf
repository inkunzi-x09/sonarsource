resource "aws_ecr_repository" "app_ecr_repo" {
  name = "sonar-repo"
}

resource "aws_ecs_cluster" "sonarCluster" {
  name = "sonar-cluster"
}

resource "aws_ecs_task_definition" "sonar_app_task" {
  family                   = "sonar-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "sonar-task",
      "image": "${aws_ecr_repository.app_ecr_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  memory                   = 512
  cpu                      = 256         
  execution_role_arn       = "${aws_iam_role.sonarEcsTasExecutionRole.arn}"
}

resource "aws_iam_role" "sonarEcsTasExecutionRole" {
  name               = "sonarEcsTasExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.sonarAssumeRolePolicy.json}"
}

data "aws_iam_policy_document" "sonarAssumeRolePolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sonarEcsTasExecutionRole_policy" {
  role       = "${aws_iam_role.sonarEcsTasExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "sonarService" {
  name            = "sonar-service"
  cluster         = "${aws_ecs_cluster.sonarCluster.id}"
  task_definition = "${aws_ecs_task_definition.sonar_app_task.arn}"
  launch_type     = "FARGATE"
  desired_count   = 3

  load_balancer {
    target_group_arn = "${var.targetGroupALBArn}"
    container_name   = "${aws_ecs_task_definition.sonar_app_task.family}"
    container_port   = 3000
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = true
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
}

resource "aws_security_group" "service_security_group" {
  name        = "${var.projectName}-service-security-group"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = ["${var.albSG}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

