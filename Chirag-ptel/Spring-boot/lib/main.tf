data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "bucket-for-tf-state-arakoo-dev"
    key    = "vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}


 output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
 }

 output "vpc_cidr_block" {
    value = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
 }

 output "default_security_group_id" {
    value = data.terraform_remote_state.vpc.outputs.default_security_group_id
 }

 output "public_subnets" {
    value = data.terraform_remote_state.vpc.outputs.public_subnets
 }

 output "private_subnets" {
    value = data.terraform_remote_state.vpc.outputs.private_subnets
 }

#  output "security_group_id" {
#   value = try(
#     data.terraform_remote_state.vpc.outputs.security_groups.*.id[
#       index(
#         [
#           for sg in data.terraform_remote_state.vpc.outputs.security_groups :
#           sg.name_prefix == "my-private-sg-"
#         ],
#         0
#       )
#     ],
#     null
#   )
# }
#hello

# data "aws_security_groups" "ecs-sgs" {
#   filter {
#     name   = "group-name"
#     values = ["${var.name}-ecs-service-sg", "${var.name}-alb-sg"]
#   }

#   filter {
#     name   = "vpc-id"
#     values = [data.terraform_remote_state.vpc.outputs.vpc_id]
#   }
# }

data "aws_security_group" "ecs_sg_data" {
  name = "${var.name}-ecs-service-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}

data "aws_security_group" "alb_sg_data" {
  name = "${var.name}-alb-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}

# data "aws_iam_roles" "roles" {
#   name_regex = "${var.name}-ecs-task-role"
# }

data "aws_iam_role" "ecs_taskexecution_role" {
  name = "${var.name}-ecs-task-role"
}

output "iam_role_arn" {
    value = data.aws_iam_role.ecs_taskexecution_role.arn
}

output "ecs_sg_id" {
    value = data.aws_security_group.ecs_sg_data.id
}

output "alb_sg_id" {
    value = data.aws_security_group.alb_sg_data.id
}
