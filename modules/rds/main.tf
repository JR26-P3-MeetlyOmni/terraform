locals {
  create          = var.create
  name_prefix_raw = "${var.name_prefix}-${var.env}"
  name_prefix_normalized = lower(join("", [
    for c in regexall(".", local.name_prefix_raw) :
    can(regex("[^a-zA-Z0-9-]", c)) ? "-" : c
  ]))
  subnet_group_name       = "${local.name_prefix_normalized}-rds-subnet"
  security_group_name     = "${local.name_prefix_normalized}-rds-sg"
  instance_identifier     = "${local.name_prefix_normalized}-postgres"
  credentials_secret_name = "${local.instance_identifier}-credentials"
  base_tags = merge(var.tags, {
    Environment = var.env
  })
}

resource "aws_db_subnet_group" "this" {
  count = local.create ? 1 : 0

  name       = local.subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(local.base_tags, {
    Name = local.subnet_group_name
  })
}

resource "aws_security_group" "this" {
  count = local.create ? 1 : 0

  name        = local.security_group_name
  description = "RDS PostgreSQL security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, {
    Name = local.security_group_name
  })
}

resource "aws_security_group_rule" "allow_sg" {
  for_each = local.create ? { for idx, sg_id in tolist(var.allowed_security_group_ids) : tostring(idx) => sg_id } : {}

  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.this[0].id
}

resource "aws_security_group_rule" "allow_cidr" {
  for_each = local.create ? toset(var.allowed_cidr_blocks) : []

  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.this[0].id
}

resource "random_password" "master" {
  count   = local.create ? 1 : 0
  length  = var.master_password_length
  special = false
}

resource "aws_secretsmanager_secret" "master" {
  count = local.create ? 1 : 0

  name = local.credentials_secret_name

  tags = merge(local.base_tags, {
    Name = local.credentials_secret_name
  })
}

resource "aws_db_instance" "this" {
  count = local.create ? 1 : 0

  identifier = local.instance_identifier

  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  engine                              = "postgres"
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  db_name                             = var.database_name
  port                                = var.port
  username                            = var.master_username
  password                            = random_password.master[0].result
  iam_database_authentication_enabled = var.iam_auth_enabled

  db_subnet_group_name       = aws_db_subnet_group.this[0].name
  vpc_security_group_ids     = [aws_security_group.this[0].id]
  publicly_accessible        = false
  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_period
  storage_encrypted          = true
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  copy_tags_to_snapshot      = true
  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  tags = merge(local.base_tags, {
    Name = local.instance_identifier
  })
}

resource "aws_secretsmanager_secret_version" "master" {
  count     = local.create ? 1 : 0
  secret_id = aws_secretsmanager_secret.master[0].id
  secret_string = jsonencode({
    engine               = "postgres"
    host                 = aws_db_instance.this[0].address
    port                 = var.port
    username             = var.master_username
    password             = random_password.master[0].result
    dbname               = var.database_name
    dbInstanceIdentifier = aws_db_instance.this[0].id
  })
}

locals {
  connection_string = local.create ? join(";", [
    "Host=${aws_db_instance.this[0].address}",
    "Port=${var.port}",
    "Database=${var.database_name}",
    "Username=${var.master_username}",
    "Password=${random_password.master[0].result}"
  ]) : null
}
