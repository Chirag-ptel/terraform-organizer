output "load_balancer_endpoint" {
  value = aws_lb.alb.dns_name
}

# output "repository_url" {
#     value = aws_ecr_repository.ecr_repo.repository_url
# }

# output "ecr_repository_name" {
#   value = aws_ecr_repository.ecr_repo.name
# }

# output "load_balancer_endpoint" {
#   value = aws_lb.alb.dns_name
# }
