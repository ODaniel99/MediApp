terraform {
  backend "s3" {
    bucket         = "media-app-tfstate-5491f18e0dd2ff63"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "media-app-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "replica"
  region = var.aws_replica_region
}
