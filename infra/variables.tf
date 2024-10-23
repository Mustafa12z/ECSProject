variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type = string
}

variable "enable_dns_support" {
  description = "Allow DNS support in the VPC."
  type = bool
  default = true
}

variable "enable_dns_hostnames" {
  description = "Allow DNS hostnames in the VPC."
  type = bool
  default = true
}

variable "vpc_name" {
  description = "Name tag for the VPC."
  type = string
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway."
  type  = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet."
  type  = string
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet."
  type  = string
}

variable "public_subnet_name" {
  description = "name for subnet"
  type = string
}

variable "private_subnet_name" {
  description = "name for subnet"
  type = string
}


variable "route_table_name" {
  description = "Name for the route table."
  type  = string
}

variable "sg_name" {
  description = "Security group name"
  type = string
}

variable "ecs-cluster-name" {
  type        = string
  description = "ecs cluster name"
}

variable "capacity_providers" {
  type = list(string)
  description = "capacity providers for ecs cluster" 
}

variable "load_balancer_type" {
  type = string
  description = "type of load balancer"
}

variable "elb_name" {
  type = string
  description = "name of the elb"
  
}
