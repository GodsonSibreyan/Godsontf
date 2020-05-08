resource "aws_security_group" "elb_app" {
  name = format("%selbappsg", var.name)

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  {
    Group = var.name
  }

}

module "elb_app" {
  source = "terraform-aws-modules/elb/aws"

  name = format("%selbapp", var.name)

  subnets         = module.vpc.private_subnets
  security_groups = [aws_security_group.elb_app.id]
  internal        = true

  listener = [
    {
      instance_port     = var.app_port
      instance_protocol = "TCP"
      lb_port           = var.app_port
      lb_protocol       = "TCP"
    },
  ]
  health_check = {
      target              = "TCP:3306/"
      interval            = 20
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
  }
  tags = {
    Group = var.name
  }

}
