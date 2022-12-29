resource "aws_lb" "consul" {
  name               = "consul"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
}

resource "aws_lb_listener" "consul" {
  load_balancer_arn = aws_lb.consul.arn
  port              = "8500"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul.arn
  }
}

resource "aws_lb_target_group" "consul" {
  name     = "consul"
  port     = 8500
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_listener" "nomad" {
  load_balancer_arn = aws_lb.consul.arn
  port              = "4646"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad.arn
  }
}

resource "aws_lb_target_group" "nomad" {
  name     = "nomad"
  port     = 4646
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_listener" "prometheus" {
  load_balancer_arn = aws_lb.consul.arn
  port              = "9090"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
}

resource "aws_lb_target_group" "prometheus" {
  name     = "prometheus"
  port     = 9090
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.consul.arn
  port              = "3000"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_lb_target_group" "grafana" {
  name     = "grafana"
  port     = 3000
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
}