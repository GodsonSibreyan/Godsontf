resource "aws_security_group" "elb_web" {
  name = format("%selbwebsg", var.name)

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = var.web_port
    to_port     = var.web_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Group = var.name
  }
}

module "elb_web" {
  source = "terraform-aws-modules/elb/aws"

  name = format("%selbweb", var.name)

  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.elb_web.id]
  internal        = false

  listener = [
    {
      instance_port     = var.web_port
      instance_protocol = "HTTP"
      lb_port           = var.web_port
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
      interval            = 20
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
      path                = "/"
      port                = 8000
    }

  tags = {
    Group = var.name
  }

}

output "elb_dns_name" {
  value = module.elb_web.this_elb_dns_name
}
