variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "nginx-lb"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "db_username" {
  description = "Database master username"
  default     = "napolitech"
}

variable "db_password" {
  description = "Database master password"
  default     = "napolitech_dev"
}

variable "db_name" {
  description = "Database name"
  default     = "pizzaria_db"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS (GB)"
  default     = 20
}

variable "db_instance_class" {
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "db_engine_version" {
  description = "MySQL engine version"
  default     = "8.0"
}

variable "rabbitmq_user" {
  description = "Usuário admin para RabbitMQ"
  default     = "admin"
}

variable "rabbitmq_pass" {
  description = "Senha admin para RabbitMQ"
  default     = "napolitech"
}
