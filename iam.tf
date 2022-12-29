resource "aws_iam_instance_profile" "consul" {
  name_prefix = "consul-server"
  role        = aws_iam_role.consul.name
}

resource "aws_iam_role" "consul" {
  name_prefix = "consul"
  path        = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

## Enables doormat SSH access
resource "aws_iam_role_policy" "consul" {
    name_prefix = "consul"

    role = aws_iam_role.consul.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "autoscaling:DescribeAutoScalingGroups",
            ]
            Effect = "Allow"
            Resource = "*"
          },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "read-only-attach" {
  role       = aws_iam_role.consul.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm-managed-attach" {
  role       = aws_iam_role.consul.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}