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
  availability_zone = "eu-west-2a"
  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_subnet" "public-subnetb" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = "eu-west-2a"

  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_subnet" "private-subnetb" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  subnet_id     = aws_subnet.public-subnet.id
  allocation_id = aws_eip.nat_eip.id
  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "private-rt" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-rtb" {
  subnet_id      = aws_subnet.private-subnetb.id
  route_table_id = aws_route_table.private.id
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

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.aws_sg.id
  ip_protocol       = "TCP"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "aws_alb_sg" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.sg_name
  }

}

resource "aws_vpc_security_group_ingress_rule" "https-alb" {
  security_group_id = aws_security_group.aws_alb_sg.id
  ip_protocol       = "TCP"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_lb" "ecs_alb" {
  name               = var.elb-name
  load_balancer_type = var.load_balancer_type
  subnets            = [aws_subnet.public-subnet.id, aws_subnet.public-subnetb.id] # Public subnets
  security_groups    = [aws_security_group.aws_alb_sg.id]

  tags = {
    Name = "ecs-fargate-alb"
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  certificate_arn   = var.certificate_arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-fargate.arn
  }
}

resource "aws_lb_target_group" "tg-fargate" {
  vpc_id   = aws_vpc.main.id
  name     = "tg-fargate-1"
  protocol = "HTTP"
  port     = "3000"
  target_type = "ip"

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_ecs_cluster" "ecs-project" {
  name = var.ecs-cluster-name
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.ecs-project.name

  capacity_providers = var.capacity_providers
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"  # ECS service principal
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    tag-key = "values"
  }
}


resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "ecs-task-definition"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode([
    {
      name      = "threatcomposer"
      image     = var.ecr-uri
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/my-app"
          "awslogs-region"        = "eu-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "main" {
  name            = "cb-service"
  cluster         = aws_ecs_cluster.ecs-project.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_task_sg.id]
    subnets          = [aws_subnet.private-subnet.id, aws_subnet.private-subnetb.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg-fargate.arn
    container_name   = "threatcomposer"
    container_port   = 3000
  }
}

resource "aws_security_group" "ecs_task_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.aws_alb_sg.id]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECS Task SG"
  }
}
