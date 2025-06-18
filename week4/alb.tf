resource "aws_lb" "lb" {
  name               = "${var.prefix}-lb" 
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.pubsub : subnet.id]

  enable_deletion_protection = true

  tags = {
    Name        = "${var.prefix}-lb"
  }
}


resource "aws_lb_target_group" "tg" {
  name        = "${var.prefix}-lb"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200,302"
    path                = "/users"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
}
    tags = {
        Name        = "${var.prefix}-tg"
    }

}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_security_group" "lb_sg" {
  name   = "${var.prefix}-lb-sg"
  vpc_id = aws_vpc.main.id
  description = "Security group for Load Balancer - allows HTTP and internal traffic"

  ingress {
    description      = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
}

ingress {
    description      = "Allow port 8000 from self"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    self = true  
}

    egress {
        description      = "Allow outgoing traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
}
    tags = {
        Name        = "${var.prefix}-lb-sg"
    }
}
