resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization_asg_instances" {
  alarm_name          = "high_cpu_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1" # The number of periods over which data is compared to the specified threshold
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2" # The namespace for the alarm's associated metric
  period              = "120" # The period in seconds over which the specified statistic is applied
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn, aws_sns_topic.omer_sns_for_alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions          = {
    AutoScalingGroupName = aws_autoscaling_group.omer-asg.name
  }
}
#cw for bastion_prometheus instance for high cpu utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization_bastion_prometheus" {
  alarm_name          = "high_cpu_utilization_bastion_prometheus"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1" # The number of periods over which data is compared to the specified threshold
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2" # The namespace for the alarm's associated metric
  period              = "120" # The period in seconds over which the specified statistic is applied
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.omer_sns_for_alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions          = {
    InstanceId = aws_instance.bastion_promethues.id
  }
}

#cw for omer-elb for high request count
resource "aws_cloudwatch_metric_alarm" "high_request_count_elb" {
  alarm_name          = "high_request_count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1" # The number of periods over which data is compared to the specified threshold
  metric_name         = "RequestCount"
  namespace           = "AWS/ELB" # The namespace for the alarm's associated metric
  period              = "120" # The period in seconds over which the specified statistic is applied
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors elb request count"
  alarm_actions       = [aws_sns_topic.omer_sns_for_alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions          = {
    LoadBalancerName = aws_elb.omer-elb.name
  }
}

# cw for omer-elb for http 4xx error count
resource "aws_cloudwatch_metric_alarm" "http_4xx_error_count_elb" {
  alarm_name          = "http_4xx_error_count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1" # The number of periods over which data is compared to the specified threshold
  metric_name         = "HTTPCode_Backend_4XX"
  namespace           = "AWS/ELB" # The namespace for the alarm's associated metric
  period              = "120" # The period in seconds over which the specified statistic is applied
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors elb http 4xx error count"
  alarm_actions       = [aws_sns_topic.omer_sns_for_alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions          = {
    LoadBalancerName = aws_elb.omer-elb.name
  }
}
# cw for omer-elb for latency
resource "aws_cloudwatch_metric_alarm" "high_latency_elb" {
  alarm_name          = "high_latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1" # The number of periods over which data is compared to the specified threshold
  metric_name         = "Latency"
  namespace           = "AWS/ELB" # The namespace for the alarm's associated metric
  period              = "120" # The period in seconds over which the specified statistic is applied
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors elb latency"
  alarm_actions       = [aws_sns_topic.omer_sns_for_alarms.arn]
  treat_missing_data  = "notBreaching"
  dimensions          = {
    LoadBalancerName = aws_elb.omer-elb.name
  }
}


