variable "tg_name" {
  type = string
  description = "Target group Name"
}

variable "load_balancer_type" {
  type        = string
  description = "type of load balancer"
}

variable "elb-name" {
  type        = string
  description = "name of the elb"

}

variable "certificate_arn" {
  type = string
  description = "Certificate ARN"
}

variable "public_subnet_id" {
  type = string
  description = "Public subnet id"
}

variable "public_subnetb_id" {
  type = string
  description = "Public subnet b id"
}

variable "sg_id" {
  type = string
  description = "Security groups id"
}

variable "vpc_id" {
  type = string
  description = "VPC ID"
  
}

