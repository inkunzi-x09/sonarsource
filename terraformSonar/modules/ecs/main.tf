resource "aws_ecr_repository" "app_ecr_repo" {
  name = "sonar-repo-${var.uniqueTagSuffix}"
  tags = {
    Name = "${var.projectName}-sonar-ecr-repo-${var.uniqueTagSuffix}"
  }
}

resource "aws_ecs_cluster" "sonarCluster" {
  name = "sonar-cluster-${var.uniqueTagSuffix}"
  tags = {
    Name = "${var.projectName}-sonar-ecs-cluster-${var.uniqueTagSuffix}"
  }
}

resource "aws_ecs_task_definition" "sonar_app_task" {
  family                   = "sonar-task-${var.uniqueTagSuffix}"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "sonar-task-${var.uniqueTagSuffix}",
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
  tags = {
    Name = "${var.projectName}-ecs-task-def-${var.uniqueTagSuffix}"
  }
}

resource "aws_iam_role" "sonarEcsTasExecutionRole" {
  name               = "sonarEcsTasExecutionRole-${var.uniqueTagSuffix}"
  assume_role_policy = "${data.aws_iam_policy_document.sonarAssumeRolePolicy.json}"
  tags = {
    Name = "${var.projectName}-iam-role-${var.uniqueTagSuffix}"
  }
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
  name            = "sonar-service-${var.uniqueTagSuffix}"
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
  tags = {
    Name = "${var.projectName}-ecs-service-${var.uniqueTagSuffix}"
  }
}

resource "aws_security_group" "service_security_group" {
  name        = "${var.projectName}-service-security-group-${var.uniqueTagSuffix}"
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

