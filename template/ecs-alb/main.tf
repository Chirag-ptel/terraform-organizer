provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "bucket-tf-state-pipeline-resources"
    key    = "APP-NAME-HOLDER/ecs-alb/terraform.tfstate"
    dynamodb_table = "dynamodb-statelock-for-tfstate-bucket"
    region = "ap-south-1"
  }
}

module "lib" {
  source = "../lib/"
  name = var.name
}

resource "aws_ecs_cluster""ecs-cluster" {
  name = "${var.name}-ecs-cluster"

  depends_on = [null_resource.build_and_push]
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "${var.name}-task"
   requires_compatibilities = ["FARGATE"]
   cpu    = var.task_definition_cpu
   memory = var.task_definition_memory
  container_definitions    = jsonencode([{
    name   = "${var.name}-task"
    image  = "${aws_ecr_repository.ecr_repo.repository_url}"
    cpu       = 256
    memory    = 512
    portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = "ecs-pipeline-resource/${var.name}"
        awslogs-region = "ap-south-1"
        awslogs-create-group = "true"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
  network_mode             = "awsvpc"
  execution_role_arn       = module.lib.iam_role_arn
  task_role_arn            = module.lib.iam_role_arn

  depends_on = [null_resource.build_and_push]
}

resource "aws_ecs_service" "ecs-service" {
  name = "${var.name}-ecs-service"
  cluster = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  enable_execute_command = true
  launch_type = "FARGATE"
  desired_count = 1

  network_configuration {
    security_groups = ["${module.lib.ecs_sg_id}"]
    assign_public_ip = true
    subnets         = module.lib.private_subnets
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name = aws_ecs_task_definition.ecs-task-definition.family
    container_port = 8080
  }
  depends_on = [null_resource.build_and_push]
}

resource "aws_lb" "alb" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${module.lib.alb_sg_id}"]
  subnets            = module.lib.public_subnets

  tags = {
    Name = "var.name"
  }
  depends_on = [null_resource.build_and_push]
}

resource  "aws_lb_target_group" "alb_target_group" {
  name               = var.name
  port               = 8080
  protocol           = "HTTP"
  target_type        = "ip"
  vpc_id             = module.lib.vpc_id
 

  health_check {
    healthy_threshold   = 2
    interval            = 60
    protocol            = "HTTP"
    timeout             = 55
    unhealthy_threshold = 2
    path                = "/students"
  }
  depends_on = [null_resource.build_and_push]
}

resource "aws_lb_listener" "alb_listener_8080" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    # redirect {
    #   port        = "443"
    #   protocol    = "HTTPS"
    #   status_code = "HTTP_301" 
    # }
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
  depends_on = [null_resource.build_and_push]
}

#########################
######   ECR   ##########
#########################

resource "aws_ecr_repository" "ecr_repo" {
  name                 = lower("${var.name}-repo")
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}


# Create docker image and push to ECR. Refer deploy script for more details
resource "null_resource" "build_and_push" {
  provisioner "local-exec" {
    working_dir = "${path.module}/../"
    command = "${path.module}/../deploy-docker.sh ${aws_ecr_repository.ecr_repo.name} ${aws_ecr_repository.ecr_repo.repository_url}:latest ${var.region}"
  }
  depends_on = [aws_ecr_repository.ecr_repo]
}

