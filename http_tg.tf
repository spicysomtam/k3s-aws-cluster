resource "aws_lb_target_group" "http" {
  count    = var.lb_enabled ? 1 : 0
  name     = "${var.prefix}-k3s-tcp-80"
  port     = 80
  protocol = "TCP"
  target_type = "instance"
  vpc_id = data.aws_vpc.var.id

  tags = var.tags
}

resource "aws_lb_target_group_attachment" "http_m" {
  target_group_arn = aws_lb_target_group.http[0].arn
  target_id = aws_instance.master[count.index].id
  count = var.lb_enabled ? var.m_num_servers : 0
  port  = 80
}

resource "aws_autoscaling_attachment" "http_a" {
  autoscaling_group_name = aws_autoscaling_group.agent.id
  alb_target_group_arn = aws_lb_target_group.http[0].arn
}