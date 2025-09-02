# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "${var.tags.Project}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id
  
  ingress {
    description = var.internal_alb ? "HTTP access from VPC" : "HTTP access from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.internal_alb ? [var.vpc_cidr] : ["0.0.0.0/0"]
  }
  
  ingress {
    description = var.internal_alb ? "HTTPS access from VPC" : "HTTPS access from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.internal_alb ? [var.vpc_cidr] : ["0.0.0.0/0"]
  }
  
  egress {
    description = "HTTP to EC2 instances"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  tags = merge(var.tags, {
    Name = "${var.tags.Project}-alb-sg"
  })
}

# Security Group for EC2 in Private Subnet
resource "aws_security_group" "ec2" {
  name_prefix = "${var.tags.Project}-ec2-"
  description = "Security group for EC2 instances in private subnet"
  vpc_id      = var.vpc_id
  
  # Allow HTTP from ALB only
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  # Outbound internet access for updates via NAT Gateway
  egress {
    description = "HTTP for package updates"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "HTTPS for package updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.tags, {
    Name = "${var.tags.Project}-ec2-sg"
  })
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 Instance in Private Subnet
resource "aws_instance" "main" {
  count                  = length(var.private_subnet_ids)
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = var.private_subnet_ids[count.index]
  iam_instance_profile   = var.instance_profile_name
  monitoring             = true
  
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
    
    tags = merge(var.tags, {
      Name = "${var.tags.Project}-ec2-root-volume"
    })
  }
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    yum update -y || { echo "Failed to update packages"; exit 1; }
    yum install -y httpd amazon-cloudwatch-agent || { echo "Failed to install packages"; exit 1; }
    systemctl start httpd || { echo "Failed to start httpd"; exit 1; }
    systemctl enable httpd || { echo "Failed to enable httpd"; exit 1; }
    echo "<h1>Secure Hello from ${var.tags.Environment} Environment</h1>" > /var/www/html/index.html
    
    # Configure CloudWatch agent with error handling
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-linux || echo "CloudWatch agent configuration failed"
  EOF
  )
  
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  
  tags = merge(var.tags, {
    Name = "${var.tags.Project}-ec2-instance-${count.index + 1}"
  })
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.tags.Project}-alb"
  internal           = var.internal_alb
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.internal_alb ? var.private_subnet_ids : var.public_subnet_ids

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  tags = var.tags
}

# ALB Target Group
resource "aws_lb_target_group" "main" {
  name     = "${var.tags.Project}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = var.tags
}

# ALB Target Group Attachment
resource "aws_lb_target_group_attachment" "main" {
  count            = length(aws_instance.main)
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.main[count.index].id
  port             = 80
}

# ALB HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ALB HTTPS Listener (requires SSL certificate)
resource "aws_lb_listener" "https" {
  count             = var.ssl_certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}