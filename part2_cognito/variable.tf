variable "region" {
  default = "eu-west-1"
}


variable "account_number" {
  default     = "AWS-account"
}


variable "profile" {
  default     = "default"
}

# AWS Elasticsearch
variable "es_domain_name" {
  default = "es-company-name"
}

variable "kibana_access" {
  default = "1"
}
