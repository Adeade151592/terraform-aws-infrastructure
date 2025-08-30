output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.ec2.alb_dns_name
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = module.security.cloudtrail_arn
}

output "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  value       = module.security.config_recorder_name
}

output "security_alerts_topic_arn" {
  description = "ARN of the SNS topic for security alerts"
  value       = module.security.sns_topic_arn
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.ec2.private_ip
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.db_port
  sensitive   = true
}