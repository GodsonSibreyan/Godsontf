resource "aws_security_group" "web" {
  name = format("%swebsg", var.name)

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = var.web_port
    to_port     = var.web_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Group = var.name
  }

}

#TODO REMOVE

resource "aws_launch_configuration" "web" {
  image_id        = var.image
  instance_type   = var.instance_type
  security_groups = [aws_security_group.web.id]
  #TODO REMOVE
  key_name = var.public_key
  name_prefix = var.name
   root_block_device {
       volume_type           = "gp2"
       volume_size           = var.size
       delete_on_termination = "true"
    }
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "web" {
  launch_configuration = aws_launch_configuration.web.id

  vpc_zone_identifier = [module.vpc.public_subnets]

  load_balancers    = [module.elb_web.this_elb_name]
  health_check_type = "EC2"

  min_size = var.web_autoscale_min_size
  max_size = var.web_autoscale_max_size

  tags = [
{
    key = "Group" 
    value = var.name
    propagate_at_launch = true
  },
]

}

variable "web_port" {
  description = "The port on which the web servers listen for connections"
  default = 8000
}

variable "web_autoscale_min_size" {
  description = "The fewest amount of EC2 instances to start"
  default = 2
}

variable "web_autoscale_max_size" {
  description = "The largest amount of EC2 instances to start"
  default = 3
}

