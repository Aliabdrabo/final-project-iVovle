variable "vpc_id" {}
variable "project_name" {}
variable "private_subnets" { type = list(string) }
variable "aws_region" { type = string }
variable "vpc_cidr_block" { type = string }

