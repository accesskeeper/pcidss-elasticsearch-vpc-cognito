terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "company-namepci-dev-terraform-state"
    key    = "es/terraform.tfstate"
    region = "eu-west-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    # Replace this with your bucket name!
    bucket = "company-namepci-dev-terraform-state"
    key    = "vpc/terraform.tfstate"
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
  user_pool = "kibana2_access"
  identity_pool        = "kibana2_access"
  cognito_role = "cognito_role"
  sms_role = "cognito_sms_role"
  identity_pool_auth_role = "Cognito_kibana_accessAuth_admin"
  identity_pool_auth_role2 = "Cognito_kibana_accessAuth_dev"
  identity_pool_auth_policy = "Cognito_kibana_accessAuth_policy_admin"
  identity_pool_auth_policy2 = "Cognito_kibana_accessAuth_policy_dev"
}


resource "aws_cognito_user_pool" "kibana_user_pool" {
  name  = local.user_pool

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
  mfa_configuration          = "ON"
  sms_authentication_message = "Your Kibana code is {####}"
  
#"arn:aws:iam::AWS-ACCOUNT:role/service-role/kibanaaccess-SMS-Role2"
  sms_configuration {
    external_id    = "4bd4c035-bd96-42c3-9879-48d2231bcd61"
    sns_caller_arn = aws_iam_role.sms_role.arn
  }
  admin_create_user_config {
    allow_admin_create_user_only  = true
  }
}

resource "aws_cognito_identity_pool" "kibana_identity_pool" {
  identity_pool_name               = local.identity_pool
  allow_unauthenticated_identities = false
}

#cognito_identity_providers {
#    client_id               = "40ibighs5rd9kch3na7n5gl1ku"
#    provider_name           = "cognito-idp.eu-west-1.amazonaws.com/eu-west-1_QUL7DPYTd"
#    server_side_token_check = false
#  }


data "aws_iam_policy" "kibana_cognito_policy" {
  arn   = "arn:aws:iam::aws:policy/AmazonESCognitoAccess"
}

data "aws_iam_policy_document" "elasticsearch_cognito_trust_policy_doc" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.es_domain_name
  user_pool_id = aws_cognito_user_pool.kibana_user_pool.id
}

#Create SMS role with TF
resource "aws_iam_role" "sms_role" {
  name               = local.sms_role
  assume_role_policy = <<CONFIG
{
"Version": "2012-10-17",
"Statement": [
     {
      "Effect" : "Allow",
      "Principal": {
        "Service": "cognito-idp.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "4bd4c035-bd96-42c3-9879-48d2231bcd61"
        }
      }
    }
  ]
}
CONFIG
}

resource "aws_iam_role_policy_attachment" "cognito_sms_role_policy" {
  role       = aws_iam_role.sms_role.name
  policy_arn = aws_iam_policy.cognito_sms_policy.arn
}

resource "aws_iam_policy" "cognito_sms_policy" {
  name        = local.sms_role
  path        = "/"
  description = "SMS policy for kibana cognito identity pool"
  policy = <<CONFIG
{
   "Version": "2012-10-17",
   "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sns:publish"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
CONFIG
}

resource "aws_iam_role" "kibana_cognito_role" {
  name               = local.cognito_role
  assume_role_policy = data.aws_iam_policy_document.elasticsearch_cognito_trust_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "kibana_cognito_role_policy" {
  role       = aws_iam_role.kibana_cognito_role.name
  policy_arn = data.aws_iam_policy.kibana_cognito_policy.arn
}

data "aws_iam_policy_document" "cognito_auth_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
      "cognito-identity:*",
      "es:ESHttp*"
    ]
    resources = ["arn:aws:es:${var.region}:${var.account_number}:domain/*"]

  }
}

data "aws_iam_policy_document" "cognito_auth_trust_relationship_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"

      values = [
        aws_cognito_identity_pool.kibana_identity_pool.id
      ]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"

      values = [
        "authenticated"
      ]
    }
  }
}

resource "aws_iam_policy" "cognito_auth_policy" {
  name        = local.identity_pool_auth_policy
  path        = "/"
  description = "Authorizaation policy for kibana cognito identity pool"

  policy = data.aws_iam_policy_document.cognito_auth_policy_doc.json

}

resource "aws_iam_role" "cognito_auth_role" {
  name  = local.identity_pool_auth_role
  assume_role_policy = data.aws_iam_policy_document.cognito_auth_trust_relationship_policy_doc.json
}

resource "aws_iam_role" "cognito_auth_role2" {
  name  = local.identity_pool_auth_role2
  assume_role_policy = data.aws_iam_policy_document.cognito_auth_trust_relationship_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "cognito_auth_role_policy" {
  role       = aws_iam_role.cognito_auth_role.name
  policy_arn = aws_iam_policy.cognito_auth_policy.arn
}

resource "aws_iam_role_policy_attachment" "cognito_auth_role_policy2" {
  role       = aws_iam_role.cognito_auth_role2.name
  policy_arn = aws_iam_policy.cognito_auth_policy.arn
}

resource "aws_cognito_user_group" "admin" {
  name         = "user-group-admins"
  user_pool_id = aws_cognito_user_pool.kibana_user_pool.id
  description  = "Managed by Terraform"
  precedence   = 41
  role_arn     = aws_iam_role.cognito_auth_role.arn
}

resource "aws_cognito_user_group" "dev" {
  name         = "user-group-devs"
  user_pool_id = aws_cognito_user_pool.kibana_user_pool.id
  description  = "Managed by Terraform"
  precedence   = 42
  role_arn     = aws_iam_role.cognito_auth_role2.arn
}

#pool ID: aws_cognito_identity_pool.kibana_identity_pool.id


# Data sources to get VPC and subnets
data "aws_vpc" "vpc" {
  id = data.terraform_remote_state.vpc.outputs.vpc_id
}

data "aws_subnet_ids" "security" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Tier = "security"
  }

}

resource "aws_elasticsearch_domain" "aws_es" {

  domain_name           = var.es_domain_name
  elasticsearch_version = var.es_version
 
  node_to_node_encryption {
    enabled = "true"
  }

  cluster_config  {
    dedicated_master_enabled = "false"
    instance_count           = "3"
    instance_type            = "m5.large.elasticsearch"
    zone_awareness_enabled   = "true"

    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  ebs_options {
    ebs_enabled = "true"
    volume_size = "200"
  }

  encrypt_at_rest {
    enabled    = "true"
    kms_key_id = "alias/aws/es"
  }

  domain_endpoint_options {
    enforce_https = "true"
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  
  vpc_options {
    # subnet_ids         = [aws_subnet.security-subnet-eu-west-1a.id, aws_subnet.security-subnet-eu-west-1c.id, aws_subnet.security-subnet-eu-west-1b.id]
    subnet_ids         = data.aws_subnet_ids.security.ids
    security_group_ids = [aws_security_group.es.id]
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  cognito_options {
    enabled = "true"
    user_pool_id = aws_cognito_user_pool.kibana_user_pool.id
    identity_pool_id = aws_cognito_identity_pool.kibana_identity_pool.id
    role_arn = "arn:aws:iam::AWS-ACCOUNT:role/cognito_role"
  }

  advanced_security_options {
	internal_user_database_enabled = "true"
        enabled = "true"
	master_user_options {
		master_user_name = var.user_name
		master_user_password = var.user_password
        }
  }

  access_policies = templatefile("${path.module}/access_policies.tpl", {
    region      = data.aws_region.current.name,
    account     = data.aws_caller_identity.current.account_id,
    domain_name = var.es_domain_name
  })

  tags = {
    Owner = "sysops"
    env   = "dev"
  }
  
}

resource "null_resource" "saveclientID" {
      depends_on = [aws_elasticsearch_domain.aws_es]
      provisioner "local-exec" {
      command = "aws cognito-idp list-user-pool-clients --user-pool-id ${aws_cognito_user_pool.kibana_user_pool.id}|grep ClientId|cut -d '\"' -f 4 > clientid.tmp"
      }
      triggers = {
#       build_number = "${timestamp()}"
       build_number = timestamp()
      }
}

#resource "null_resource" "security" {
#    depends_on = [aws_elasticsearch_domain.aws_es]
#    provisioner "local-exec" {
#      command = "bash users.sh"
#    }
#}
