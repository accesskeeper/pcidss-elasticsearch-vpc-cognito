#VPC ID
data "aws_vpc" "company-name-dev" {
  id = data.terraform_remote_state.vpc.outputs.vpc_id
}


resource "aws_security_group" "es" {
  name        = "es"
  description = "Allow ES ports"
  vpc_id      = data.aws_vpc.company-name-dev.id

  ingress {
    description = "TLS port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
#    cidr_blocks = [data.aws_vpc.company-name-dev.cidr_block]  #for vpc deployment
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project        = "company-name"
    Environment    = "development"
    Name           = "company-name-dev"
    Terraform      = true
    LastModifiedBy = data.aws_caller_identity.current.arn
  }
}


