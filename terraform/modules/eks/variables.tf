variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}


variable "private_subnets" {
  type = list(string)
}

variable "aws_region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

