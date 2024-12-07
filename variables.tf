variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_count" {
  description = "Number of public/private subnets to create"
  type        = number
}

variable "name" {
  description = "Name prefix for the VPC and associated resources"
  type        = string
}

variable "tags" {
  type = map(any)
}

variable "aws_region" {
  type    = string
}