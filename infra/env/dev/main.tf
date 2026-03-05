terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.0"
    }

  }
}

provider "aws" {
  region = var.aws_region
}



provider "opensearch" {

  url = "https://${module.opensearch.domain_endpoint}"

  username = "admin"
  password = "SuperPassword123!"

}

