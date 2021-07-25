provider "aws" {
  region = var.region
  profile = var.profile
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "euw1-aws-eks-cluster-terraform-state"
    key = "euw1-aws-eks-cluster/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "euw1-aws-eks-cluster-tf-state"
    encrypt = true
  }
}