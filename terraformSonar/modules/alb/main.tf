resource "aws_lb" "sonarLB" {
  name = "${var.projectName}-lb"
  internal = false
  load_balancer_type = "application"
  subnets = var.pub_subnet_ids[*]
}

resource "aws_lb_target_group" "sonarAlbTg" {
  name        = "${var.projectName}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "webLst" {
  load_balancer_arn = aws_lb.sonarLB.arn
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.sonarAlbTg.id
    type = "forward"
  }
}

resource "aws_security_group" "sonarAlbSG" {
  name        = "${var.projectName}-alb-security-group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.nat_gateway_ip
    content {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["${ingress.value}/32"]
    }
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [cidrsubnet(var.vpcCidrBlock, 8, 4), cidrsubnet(var.vpcCidrBlock, 8, 5), cidrsubnet(var.vpcCidrBlock, 8, 6)]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}