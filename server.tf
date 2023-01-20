

resource "aws_autoscaling_group" "consul" {
  name_prefix          = "hashistack-server"
  max_size                  = 3
  min_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 3
  force_delete              = true
  launch_configuration      = aws_launch_configuration.consul.name
  target_group_arns         = [
    aws_lb_target_group.consul.arn,
    aws_lb_target_group.nomad.arn
  ]
  vpc_zone_identifier       = module.vpc.private_subnets

  tag {
    key                 = "consul"
    value               = "server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "hashistack-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "owner"
    value               = "nwales"
    propagate_at_launch = false
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      target_group_arns
    ]
  }
}

resource "aws_launch_configuration" "consul" {
  iam_instance_profile = aws_iam_instance_profile.consul.name
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = "m4.2xlarge"
  name_prefix          = "consul"
  security_groups      = [aws_security_group.consul.id]
  user_data            = templatefile("${path.module}/templates/userdata_server.sh.tftpl", { })

  lifecycle {
    create_before_destroy = true
  }
}