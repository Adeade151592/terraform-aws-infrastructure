output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "config_recorder_name" {
  description = "Name of the Config recorder"
  value       = aws_config_configuration_recorder.main.name
}

output "vpc_flow_logs_group_arn" {
  description = "ARN of the VPC Flow Logs CloudWatch group"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for security alerts"
  value       = aws_sns_topic.alerts.arn
}