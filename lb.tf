resource "aws_lb" "lb" {
  count             = var.lb_enabled ? 1 : 0
  name               = "${var.prefix}-k3s"
  internal           = var.lb_internal
  load_balancer_type = "network"
  subnets = var.lb_subnet_ids
  tags = var.tags
}

resource "aws_lb_listener" "k8s" {
  count             = var.api_on_lb && var.lb_enabled ? 1 : 0
  load_balancer_arn = aws_lb.lb[0].arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s[0].arn
  }
}

resource "aws_lb_listener" "https" {
  count             = var.lb_enabled ? 1 : 0
  load_balancer_arn = aws_lb.lb[0].arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https[0].arn
  }
}

resource "aws_lb_listener" "http" {
  count             = var.lb_enabled ? 1 : 0
  load_balancer_arn = aws_lb.lb[0].arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http[0].arn
  }
}