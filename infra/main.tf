resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block

  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_block

  tags = {
    Name = var.private_subnet_name
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "public-rt" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "aws_sg" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.sg_name
  }

}

# Create an Application Load Balancer
resource "aws_lb" "ecs_alb" {
  name               = var.elb_name
  load_balancer_type = var.load_balancer_type
  subnets            = ["subnet-public1", "subnet-public2"]  # Public subnets

  tags = {
    Name = "ecs-fargate-alb"
  }
}

# Create a Listener for HTTP (port 80)
resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

# Modify the Target Group in your Module to reference the ALB
resource "aws_lb_target_group" "example" {
  name     = "tg-fargate-example"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

module "ecs-fargate" {
  source = "umotif-public/ecs-fargate/aws"
  version = "~> 6.1.0"

  name_prefix        = "ecs-fargate-example"
  vpc_id             = aws_vpc.main.id
  private_subnet_ids = ["subnet-private1", "subnet-private2"]  # Keep the private subnets for ECS tasks

  cluster_id         = aws_ecs_cluster.ecs-project.id

  task_container_image   = "marcincuber/2048-game:latest"
  task_definition_cpu    = 256
  task_definition_memory = 512

  task_container_port             = 80
  task_container_assign_public_ip = false  # Assign public IP to load balancer, not ECS tasks

  target_groups = [
    {
      target_group_name = aws_lb_target_group.example.name  # Use the target group created above
      container_port    = 80
    }
  ]

  health_check = {
    port = "traffic-port"
    path = "/"
  }

  tags = {
    Environment = "test"
    Project = "Test"
  }
}


resource "aws_ecs_cluster" "ecs-project" {
  name = var.ecs-cluster-name
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.ecs-project.name

  capacity_providers = var.capacity_providers
}

module "ecs-fargate" {
  source = "umotif-public/ecs-fargate/aws"
  version = "~> 6.1.0"

  name_prefix        = "ecs-fargate-example"
  vpc_id             = "vpc-abasdasd132"
  private_subnet_ids = ["subnet-abasdasd132123", "subnet-abasdasd132123132"]

  cluster_id         = aws_ecs_cluster.cluster.id

  task_container_image   = "marcincuber/2048-game:latest"
  task_definition_cpu    = 256
  task_definition_memory = 512

  task_container_port             = 80
  task_container_assign_public_ip = true

  target_groups = [
    {
      target_group_name = "tg-fargate-example"
      container_port    = 80
    }
  ]

  health_check = {
    port = "traffic-port"
    path = "/"
  }

  tags = {
    Environment = "test"
    Project = "Test"
  }
}