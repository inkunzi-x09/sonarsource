output "targetGroupALBArn" {
  value = aws_lb_target_group.sonarAlbTg.arn
}

output "sonarAlbSG" {
  value = aws_security_group.sonarAlbSG.id
}