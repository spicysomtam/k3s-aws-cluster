resource "aws_lb_target_group" "k8s" {
  count    = var.api_on_lb && var.lb_enabled ? 1 : 0
  name     = "${var.prefix}-k3s-tcp-6443"
  port     = 6443
  protocol = "TCP"
  target_type = "instance"
  vpc_id = data.aws_vpc.var.id

  tags = var.tags
}

resource "aws_lb_target_group_attachment" "k8s_m" {
  target_group_arn = aws_lb_target_group.k8s[0].arn
  target_id        = aws_instance.master[count.index].id
  count            = var.api_on_lb && var.lb_enabled ? var.m_num_servers : 0
  port             = 6443
}