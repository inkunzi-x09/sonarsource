resource "aws_lb" "sonarLB" {
  name = "sonarLB"
  internal = false
  load_balancer_type = "application"
  subnets = var.pub_subnet_ids[*]
}

resource "aws_lb_target_group" "sonarAlbTg" {
  name        = "sonar-target-group"
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
  name        = "sonar-alb-security-group"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "sonarAlbSG_id" {
  value = aws_security_group.sonarAlbSG.id
}

output "sonarLbListener" {
  value = aws_lb_listener.webLst
}

output "sonarAlbTg_id" {
  value = aws_lb_target_group.sonarAlbTg.id
}

output "load_balancer_ip" {
  value = aws_lb.sonarLB.dns_name
}