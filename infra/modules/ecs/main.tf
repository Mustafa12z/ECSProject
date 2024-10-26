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
          Service = "ecs-tasks.amazonaws.com" # ECS service principal
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

resource "aws_cloudwatch_log_group" "ecs_threatmodel_log" {
  name              = "/ecs/threatmodel-log"
  retention_in_days = 7
}

resource "aws_iam_policy" "ecs_cloudwatch_policy" {
  name = "ecs_cloudwatch_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:eu-west-2:*:log-group:/ecs/threatmodel-log:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_cloudwatch_policy.arn
}

resource "aws_ecs_task_definition" "app" {
  family                   = "ecs-task-definition"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 4096
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([
    {
      name      = "threatcomposer"
      image     = "590184076390.dkr.ecr.eu-west-2.amazonaws.com/ecs-project:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      logConfiguration = {
        logDriver : "awslogs"
        options : {
          "awslogs-group" : "/ecs/threatmodel-log"
          "awslogs-create-group" : "true"
          "awslogs-region" : "eu-west-2"
          "awslogs-stream-prefix" : "ecs"
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
    security_groups  = [var.sg_id]
    subnets          = [var.private_subnet_id, var.private_subnetb_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "threatcomposer"
    container_port   = 3000
  }
}
