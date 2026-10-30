# --------------------------------------------------
# APPLICATION LOAD BALANCER
# --------------------------------------------------

# Public-facing ALB spanning our two public subnets.
resource "aws_lb" "web" {
  name               = "secure-vpc-alb"
  internal           = false
  load_balancer_type = "application"

  # Reuse the ALB Security Group created earlier.
  security_groups = [aws_security_group.alb.id]

  # Deploy ALB nodes across two Availability Zones.
  subnets = module.vpc.public_subnet_ids

  # Allow Terraform to delete the ALB during cleanup.
  enable_deletion_protection = false

  tags = {
    Name = "secure-vpc-alb"
  }
}

# --------------------------------------------------
# TARGET GROUP
# --------------------------------------------------

# A target group manages the backend EC2 instances.
resource "aws_lb_target_group" "web" {
  name        = "secure-vpc-web-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  # ALB checks this endpoint to determine whether
  # an EC2 web server can receive traffic.
  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "secure-vpc-web-tg"
  }
}

# --------------------------------------------------
# REGISTER THE TWO PRIVATE EC2 INSTANCES
# --------------------------------------------------

# Register each web instance in the target group.
resource "aws_lb_target_group_attachment" "web" {
  count = 2

  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# --------------------------------------------------
# HTTP LISTENER
# --------------------------------------------------

# Listen for incoming HTTP requests on port 80
# and forward them to our web server target group.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
