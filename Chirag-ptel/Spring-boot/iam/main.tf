provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "bucket-tf-state-pipeline-resources"
    key    = "iam/01/terraform.tfstate"
    dynamodb_table = "dynamodb-statelock-for-tfstate-bucket"
    region = "ap-south-1"
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "${var.name}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_cloudwatch_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_SSM_policy" {
#   role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
# }


