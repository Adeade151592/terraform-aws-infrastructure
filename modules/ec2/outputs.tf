output "instance_id" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.main[*].id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "private_ip" {
  description = "Private IPs of the EC2 instances"
  value       = aws_instance.main[*].private_ip
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}