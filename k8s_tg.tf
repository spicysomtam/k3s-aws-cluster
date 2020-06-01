resource "aws_lb_target_group" "k8s" {
  count    = var.api_on_lb ? 1 : 0
  name     = "${var.prefix}-k3s-tcp-6443"
  port     = 6443
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

resource "aws_lb_target_group_attachment" "k8s_m" {
  target_group_arn = aws_lb_target_group.k8s[0].arn
  target_id        = aws_instance.master[count.index].id
  count            = var.api_on_lb ? var.m_num_servers : 0
  port             = 6443
}