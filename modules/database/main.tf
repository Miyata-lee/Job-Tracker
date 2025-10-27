resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group-${var.environment}"
  subnet_ids = [var.private_subnet_1_id, var.private_subnet_2_id]

  tags = {
    Name = "${var.project_name}-db-subnet-group-${var.environment}"
  }
}


resource "aws_db_instance" "mysql" {
  identifier     = "${var.project_name}-mysql-${var.environment}"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  allocated_storage = var.db_storage_allocated
  storage_type      = "gp2"
  storage_encrypted = false

 
  multi_az = true

 
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false


  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  copy_tags_to_snapshot   = true


  maintenance_window           = "sun:04:00-sun:05:00"
  auto_minor_version_upgrade   = true
  skip_final_snapshot          = false
  final_snapshot_identifier    = "${var.project_name}-mysql-final-snapshot-${var.environment}-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = {
    Name = "${var.project_name}-mysql-${var.environment}"
  }

  depends_on = [aws_db_subnet_group.main]
}