resource "aws_lb" "api_lb" {
  name               = "${var.prefix}-k8sApi"
  internal           = var.api_lb_internal
  load_balancer_type = "network"
  #subnets = data.aws_subnet_ids.default.ids
  subnets = module.vpc.private_subnets
}

resource "aws_lb_listener" "api_k8s" {
  load_balancer_arn = aws_lb.api_lb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_k8s.arn
  }
}

resource "aws_lb_target_group" "api_k8s" {
  name     = "${var.prefix}-k8sApi-tcp-6443"
  port     = 6443
  protocol = "TCP"
  target_type = "instance"
  vpc_id = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "api_k8s_m" {
  target_group_arn = aws_lb_target_group.api_k8s.arn
  target_id        = module.k3s.master_instance[count.index].id
  count            = var.m_num_servers
  port             = 6443
}