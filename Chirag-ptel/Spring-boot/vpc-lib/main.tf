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

 output "public_subnets" {
    value = data.terraform_remote_state.vpc.outputs.public_subnets
 }

 output "private_subnets" {
    value = data.terraform_remote_state.vpc.outputs.private_subnets
 }
