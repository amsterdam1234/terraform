resource "aws_autoscaling_group" "omer-asg" {
  # num of instances
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  #load balancer
  load_balancers            = [aws_elb.omer-elb.name]
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier = [
    # Creating EC2 instances in private subnet
    aws_subnet.private_subnet.id,
  ]

  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
}