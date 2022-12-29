resource "aws_autoscaling_group" "consul_client" {
  name_prefix          = "hashistack-client"
  max_size                  = 20
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.consul_client.name
  target_group_arns         = [
    aws_lb_target_group.consul.arn
  ]
  vpc_zone_identifier       = module.vpc.private_subnets

  tag {
    key                 = "consul"
    value               = "server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "hashistack-client"
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

resource "aws_launch_configuration" "consul_client" {
  iam_instance_profile = aws_iam_instance_profile.consul.name
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = "m5.large"
  name_prefix          = "consul"
  security_groups      = [aws_security_group.consul.id]
  user_data            = templatefile("${path.module}/templates/userdata_client.sh.tftpl", { })

  lifecycle {
    create_before_destroy = true
  }
}