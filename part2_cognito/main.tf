terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "company-namepci-dev-terraform-state"
    key    = "cognito/terraform.tfstate"
    region = "eu-west-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "es" {
  backend = "s3"
  config = {
    # Replace this with your bucket name!
    bucket = "company-namepci-dev-terraform-state"
    key    = "es/terraform.tfstate"
    region = "eu-west-1"
    encrypt        = true
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

locals {
  identity_pool        = "kibana2_access"
  clientid             = "nsil3bp07sjeslhffd6qcnfts"
}

resource "null_resource" "security" {
      triggers = {
       build_number = "${timestamp()}"
      }
    provisioner "local-exec" {
      command = "bash users.sh"
    }
}

#data "template_file" "clientid" {
#    template = "../es_vpc/clientid.tmp"
#}

#data "local_file" "clientid" {
#    filename = data.template_file.clientid.rendered
#}

#data "local_file" "clientid" {
#    filename = "../es_vpc/clientid.tmp"
#}


#resource "null_resource" "security" {
#      triggers = {
#       build_number = "${timestamp()}"
#      }
#    provisioner "local-exec" {
#      command = "echo ${data.local_file.clientid.content}"
#    }
#}

#output "KN_OUTPUT" {
#  value = data.local_file.clientid.content
#}


#resource "aws_cognito_identity_pool" "kibana_identity_pool" {
#  identity_pool_name               = local.identity_pool
#  allow_unauthenticated_identities = false
#
#  cognito_identity_providers {
#    #client_id               = data.local_file.clientid.content
#    client_id               = local.clientid
#    provider_name           = "cognito-idp.eu-west-1.amazonaws.com/${data.terraform_remote_state.es.outputs.user_pool_id}"
#    server_side_token_check = false
#  }
#}


#BELOW CODE does not want to work with ${data.local_file.clientid.content}. Using instead additional local definition ${local.clientid}. It is exactly same strings.very strange
resource "aws_cognito_identity_pool_roles_attachment" "this" {
  identity_pool_id = data.terraform_remote_state.es.outputs.identity_pool_id

  role_mapping {
    identity_provider         = "cognito-idp.eu-west-1.amazonaws.com/${data.terraform_remote_state.es.outputs.user_pool_id}:${local.clientid}"
    ambiguous_role_resolution = "Deny"
    type                      = "Token"
  }

  roles = {
    "authenticated" = data.terraform_remote_state.es.outputs.cognito_role_arn
  }
}
