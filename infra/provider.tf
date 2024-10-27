terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
    
  }
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

terraform {
  backend "s3" {
    bucket         = "ecs-project-bucket"
    key            = "terraform/state/ecs.tfstate"
    region         = "eu-west-2"
    encrypt        = true
  }
}
