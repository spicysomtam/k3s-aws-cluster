#
# Provider Configuration
#

provider "aws" {
  region = var.aws_region
}

provider "random" {}