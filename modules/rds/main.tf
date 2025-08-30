# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.tags.Project}-rds-"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.ec2_security_group]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.tags, {
    Name = "${var.tags.Project}-rds-sg"
  })
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.tags.Project}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  
  tags = merge(var.tags, {
    Name = "${var.tags.Project}-db-subnet-group"
  })
}

# Get credentials from Secrets Manager
data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = var.db_secret_arn
}

locals {
  secret_string = data.aws_secretsmanager_secret_version.db_credentials.secret_string
  decoded_secret = can(jsondecode(local.secret_string)) ? jsondecode(local.secret_string) : {}
  db_creds = (can(local.decoded_secret.username) && can(local.decoded_secret.password)) ? local.decoded_secret : null
}

# RDS Instance
resource "aws_db_instance" "main" {
  count = 1
  identifier     = "${var.tags.Project}-database"
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  
  db_name  = var.db_name
  username = local.db_creds != null ? local.db_creds.username : var.db_username
  password = local.db_creds != null ? local.db_creds.password : var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection
  
  tags = merge(var.tags, {
    Name = "${var.tags.Project}-rds-instance"
  })
}