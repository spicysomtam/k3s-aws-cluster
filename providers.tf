#
# Provider Configuration
#

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      #version = "~> 2.3"
    }
    aws = {
      source  = "hashicorp/aws"
      #version = "~> 2.69"
    }
  }
}
