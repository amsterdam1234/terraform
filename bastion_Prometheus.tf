resource "aws_instance" "bastion" {
  ami                    = "ami-00c39f71452c08778"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.omer_key.key_name # Key pair for the EC2 instances
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.prometheus_instance_profile.name # IAM role for the EC2 instances
  user_data = filebase64("userdata_bastoin_prometheus.sh")
  tags                   = {
    Name = "Bastion_Prometheus_Host"
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion_sg"
  vpc_id = aws_vpc.main_vpn.id
  ingress {
    description = "Allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow prometheus"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "Allow prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "prometheus_role" { # IAM role for the EC2 instances
  name = "prometheus_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "prometheus_policy" { # Policy for the IAM role
  name        = "prometheus_ec2_policy"
  description = "Policy for Prometheus to describe EC2 instances and tags"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prometheus_policy_attachment" { # Attach the policy to the role
  role       = aws_iam_role.prometheus_role.name
  policy_arn = aws_iam_policy.prometheus_policy.arn
}

resource "aws_iam_instance_profile" "prometheus_instance_profile" { # Instance profile for the EC2 instances
  name = "prometheus_instance_profile"
  role = aws_iam_role.prometheus_role.name
}