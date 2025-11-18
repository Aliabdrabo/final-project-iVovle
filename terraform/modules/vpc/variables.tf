variable "project_name" {
  type        = string
}

variable "availability_zones" {
  type = list(string)
}

variable "cidr_block" {
  type = list(string)
}

variable "default_route" {
  type = string
}

variable "private_cidr_blocks" {
  type = list(string) 
}

variable "public_cidr_blocks" {
  type = list(string) 
}
