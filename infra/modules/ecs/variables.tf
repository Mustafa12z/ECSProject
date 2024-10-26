variable "ecs-fargate-name" {
  type        = string
  description = "name of ecs fargate"
}


variable "task-def-cpu" {
  type        = number
  description = "task definition cpu"
}

variable "ecs-cluster-name" {
  type        = string
  description = "ecs cluster name"
}

variable "capacity_providers" {
  type        = list(string)
  description = "capacity providers for ecs cluster"
}


variable "sg_id" {
  type = string
  description = "Security groups id"
}

variable "target_group_arn" {
    type = string
    description = "Target group"
  
}

variable "private_subnet_id" {
  type = string
  description = "Private subnet A"
}

variable "private_subnetb_id" {
  type = string
  description = "Private subnet B"
}