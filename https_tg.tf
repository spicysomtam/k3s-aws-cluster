resource "aws_lb_target_group" "https" {
  name     = "${var.prefix}-k3s-tcp-443"
  port     = 443
  protocol = "TCP"
  target_type = "instance"
  vpc_id = data.aws_vpc.var.id

  # oddily we have to specify stickiness and then disable it to allow protocol = "TCP"!
  stickiness {
      type = "lb_cookie"
      enabled = false
  }

  tags = var.tags
}

resource "aws_lb_target_group_attachment" "https_m" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = aws_instance.master[count.index].id
  count = var.m_num_servers
  port             = 443
}

resource "aws_lb_target_group_attachment" "https_a" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = aws_instance.agent[count.index].id
  count = var.a_num_servers
  port             = 443
}