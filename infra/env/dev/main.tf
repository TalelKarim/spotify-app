terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    tls = {
      source = "hashicorp/tls"
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

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}




provider "opensearch" {

  url         = "https://${module.opensearch.domain_endpoint}"
  healthcheck = false

}

