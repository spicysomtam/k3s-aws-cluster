resource "aws_lb_target_group" "k8s" {
  name     = "${var.prefix}-k3s-tcp-6443"
  port     = 6443
  protocol = "TCP"
  target_type = "instance"
  vpc_id = data.aws_vpc.default.id

  # oddily we have to specify stickiness and then disable it to allow protocol = "TCP"!
  stickiness {
      type = "lb_cookie"
      enabled = false
  }
}

resource "aws_lb_target_group_attachment" "k8s_m" {
  target_group_arn = aws_lb_target_group.k8s.arn
  target_id        = aws_instance.master[count.index].id
  count = var.m_num_servers
  port             = 6443
}