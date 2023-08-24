provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "bucket-tf-state-pipeline-resources"
    key    = "security-groups/01/terraform.tfstate"
    dynamodb_table = "dynamodb-statelock-for-tfstate-bucket"
    region = "ap-south-1"
  }
}

module "lib" {
  source = "../lib/"
  name   = var.name
  isSG = true
}

resource "aws_security_group" "service_security_group" {
  name        = "${var.name}-ecs-service-sg"
  vpc_id      = module.lib.vpc_id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.lb_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb_security_group" {
  name        = "${var.name}-alb-sg"
  vpc_id      = module.lib.vpc_id

 ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}