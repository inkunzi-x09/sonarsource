resource "aws_lb" "sonarLB" {
  name = "${var.projectName}-lb-${var.uniqueTagSuffix}"
  internal = false
  load_balancer_type = "application"
  subnets = var.pub_subnet_ids[*]
  security_groups = [aws_security_group.sonarAlbSG.id]
  tags = {
    Name = "${var.projectName}-alb-${var.uniqueTagSuffix}"
  }
}

resource "aws_lb_target_group" "sonarAlbTg" {
  name        = "${var.projectName}-target-group-${var.uniqueTagSuffix}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags = {
    Name = "${var.projectName}-target-group-${var.uniqueTagSuffix}"
  }
}

resource "aws_lb_listener" "webLst" {
  load_balancer_arn = aws_lb.sonarLB.arn
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.sonarAlbTg.id
    type = "forward"
  }
  tags = {
    Name = "${var.projectName}-alb-listener-${var.uniqueTagSuffix}"
  }
}

resource "aws_security_group" "sonarAlbSG" {
  name        = "${var.projectName}-alb-security-group-${var.uniqueTagSuffix}"
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

  dynamic "ingress" {
    for_each = var.nat_gateway_ip
    content {
      from_port = 443
      to_port = 443
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
  tags = {
    Name = "${var.projectName}-sg-alb-${var.uniqueTagSuffix}"
  }
}