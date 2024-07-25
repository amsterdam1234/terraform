resource "aws_sns_topic" "omer_sns_for_alarms" {
  name = "omer_sns"
}

resource "aws_sns_topic_subscription" "omer_email" {
  topic_arn = aws_sns_topic.omer_sns_for_alarms.arn
  protocol  = "email"
  endpoint  = "omeramsterdam11@gmail.com"
}

resource "aws_sns_topic_subscription" "omer_sms" {
  topic_arn = aws_sns_topic.omer_sns_for_alarms.arn
  protocol  = "sms"
  endpoint  = "+9720544784039"
}


