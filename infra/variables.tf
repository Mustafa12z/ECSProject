

variable "enable_dns_support" {
  description = "Allow DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Allow DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name tag for the VPC."
  type        = string
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway."
  type        = string
}



variable "public_subnet_name" {
  description = "name for subnet"
  type        = string
}

variable "private_subnet_name" {
  description = "name for subnet"
  type        = string
}


variable "route_table_name" {
  description = "Name for the route table."
  type        = string
}

variable "sg_name" {
  description = "Security group name"
  type        = string
}

variable "tg_name" {
  type = string
  description = "Target group Name"
}

variable "ecs-cluster-name" {
  type        = string
  description = "ecs cluster name"
}

variable "certificate_arn" {
  type = string
  description = "Certificate ARN"
}

variable "capacity_providers" {
  type        = list(string)
  description = "capacity providers for ecs cluster"
}

variable "load_balancer_type" {
  type        = string
  description = "type of load balancer"
}

variable "elb-name" {
  type        = string
  description = "name of the elb"

}

variable "ecs-fargate-name" {
  type        = string
  description = "name of ecs fargate"
}

variable "ecr-uri" {
  description = "uri for the container in ecr"
}

variable "task-def-cpu" {
  type        = number
  description = "task definition cpu"
}

variable "hosted_zone" {
  type = string
  description = "The hosted zone"
}

variable "subdomain_name" {
  type = string
  description = "The specified format for the assignment"
}

variable "aws_access_key_id" {}

variable "aws_secret_access_key" {}

variable "aws_region" {}