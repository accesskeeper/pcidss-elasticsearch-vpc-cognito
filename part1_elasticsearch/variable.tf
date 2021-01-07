variable "account_number" {
  default     = "AWS-ACCOUNT"
}

# AWS Elasticsearch
variable "es_domain_name" {
  default = "es-company-name"
}

variable "kibana_access" {
  default = "1"
}

variable "region" {
  default     = "eu-west-1"
}

variable "profile" {
  default     = "default"
}

variable "es_version" {}
variable "user_name" {}
variable "user_password" {}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map
  default     = {"name"="es"}
}

# Service Link Role
variable "create_service_link_role" {
  description = "Create service link role for AWS Elasticsearch Service"
  type        = bool
  default     = true
}

variable "vpcid" {
  default = "vpc-08f5977ecc2b6c03b"
}

variable "vpc_name" {
  default = "company-namepci-dev vpc"
}
