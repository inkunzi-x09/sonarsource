resource "aws_lb" "sonarLB" {
  name = "sonarLB"
  internal = false
  load_balancer_type = "application"
  subnets = var.pub_subnet_ids[*]
}

resource "aws_lb_listener" "webLst" {
  load_balancer_arn = aws_lb.sonarLB.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code = "200"
      message_body = "OK"
    }
  }
}