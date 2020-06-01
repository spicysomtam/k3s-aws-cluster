resource "aws_lb" "lb" {
  name               = "${var.prefix}-k3s"
  internal           = var.lb_internal
  load_balancer_type = "network"
  subnets = var.lb_subnet_ids
  tags = var.tags
}

resource "aws_lb_listener" "k8s" {
  count             = var.api_on_lb ? 1 : 0
  load_balancer_arn = aws_lb.lb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s[0].arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}