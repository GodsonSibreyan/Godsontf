resource "aws_security_group" "rds" {
  name = format("%srdssg", var.name)

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  tags = {
    Group = var.name
  }

}

#module "rds" {
#  source = "terraform-aws-modules/rds/aws"

#  identifier = var.db_identifier

#  engine            = "mysql"
#  engine_version    = "5.7"
 # instance_class    = "db.t2.micro"
  #allocated_storage = var.db_allocated_storage

  #name = var.db_name
  #username = var.db_username
  #password = var.db_password
  #port     = var.db_port

 # vpc_security_group_ids = [aws_security_group.rds.id]

 # maintenance_window = var.db_maintenance_window
 # backup_window      = var.db_backup_window

  # disable backups to create DB faster
  #backup_retention_period = var.db_backup_retention_period
  #create_db_parameter_group = false
  #create_db_option_group = false
  #parameter_group_name = "default.mysql5.7"
  #subnet_ids = module.vpc.database_subnets

  #tags = {
  #  Group = var.name
 # }

#}
resource "aws_db_instance" "tfrds" {
identifier = var.db_identifier
allocated_storage = "10"
storage_type = "gp2"
engine = "mysql"
engine_version = "5.7"
instance_class = "db.t2.micro"
name = "zippyops"
username = "zippyops"
password = "zippyops"
availability_zone = "us-east-1a"
backup_retention_period = "7"
backup_window = "00:05-00:35"
skip_final_snapshot = true

subnet_ids = module.vpc.database_subnets
vpc_security_group_ids = [aws_security_group.rds.id]
#db_subnet_group_name = aws_db_subnet_group.tfdbsubnetgroup.id
#vpc_security_group_ids = [aws_security_group.dbsg.id]

  provisioner "local-exec" {
    command = "echo ${aws_db_instance.tfrds.address} >> /var/lib/jenkins/workspace//endpoint"
}
  tags = {
    Group = var.name
  }
}

output "rds_link" {
  description = "The address of the RDS Instnce"
  value = aws_db_instance.tfrds.address
}
variable "db_identifier" {
  description = "The name of the RDS instance"
  default = "django"
}

variable "db_allocated_storage" {
  description = "The allocated storage in GB"
  default = 5
}

variable "db_name" {
  description = "The DB name to create"
  default = "zippyops"
}

variable "db_username" {
  description = "Username for the master DB user"
  default = "zippyops"
}

variable "db_password" {
  description = "Password for the master DB user"
  default = "zippyops"
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  default = 3306
}

variable "db_maintenance_window" {
  description = "The window to perform maintenance in"
  default = "Mon:00:00-Mon:03:00"
}

variable "db_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  default = "03:00-06:00"
}

variable "db_backup_retention_period" {
  description = "The days to retain backups for"
  default = 0
}
