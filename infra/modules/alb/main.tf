resource "aws_lb" "ecs_alb" {
  name               = var.elb-name
  load_balancer_type = var.load_balancer_type
  subnets            = [var.public_subnet_id, var.public_subnetb_id]
  security_groups    = [var.sg_id]

  tags = {
    Name = "ecs-fargate-alb"
  }
}

resource "aws_lb_listener" "ecs_alb_listener_ttph" {
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
  certificate_arn   = var.certificate_arn
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
  vpc_id      = var.vpc_id
  name        = var.tg_name
  protocol    = "HTTP"
  port        = "3000"
  target_type = "ip"

  health_check {
    path = "/"
    port = "traffic-port"
  }
}
