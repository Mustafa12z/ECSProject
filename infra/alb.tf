resource "aws_lb" "ecs_alb" {
  name               = var.elb-name
  load_balancer_type = var.load_balancer_type
  subnets            = [aws_subnet.public-subnet.id, aws_subnet.public-subnetb.id]
  security_groups    = [aws_security_group.aws_sg.id]

  tags = {
    Name = "ecs-fargate-alb"
  }
}

resource "aws_lb_listener" "ecs_alb_listener_http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  certificate_arn   = "arn:aws:acm:eu-west-2:084375562247:certificate/aa791c38-9818-4b37-bd2d-49268a2e2a6e"
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.tg-fargate.arn
      }
    }
  }

}

resource "aws_lb_target_group" "tg-fargate" {
  vpc_id      = aws_vpc.main.id
  name        = "tg-fargate-1"
  protocol    = "HTTP"
  port        = "3000"
  target_type = "ip"

  health_check {
    path = "/"
    port = "traffic-port"
  }
}
