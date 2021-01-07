#!/bin/bash

export ES_DOMAIN_NAME=`cat terraform.tfvars|grep es_domain_name| cut -d '"' -f2` 
export ES_DOMAIN_USER=`cat terraform.tfvars|grep user_name| cut -d '"' -f2`
export ES_DOMAIN_PASSWORD=`cat terraform.tfvars|grep user_password| cut -d '"' -f2`
#export ES_ENDPOINT=$(aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --output text --query "DomainStatus.Endpoint")
export ES_ENDPOINT=$(aws es describe-elasticsearch-domain --domain-name es-company-name --output text |grep ENDPOINTS|cut -d$'\t' -f2)

curl -sS -u "${ES_DOMAIN_USER}:${ES_DOMAIN_PASSWORD}" \
    -X PUT \
    https://${ES_ENDPOINT}/_opendistro/_security/api/roles/dev?pretty \
    -H 'Content-Type: application/json' \
    -d'
{
  "cluster_permissions": [
  "cluster_composite_ops",
  "create_index"
  ],
  "index_permissions": [{
    "index_patterns": [
      "application*"
    ],
    "dls": "",
    "fls": [],
    "masked_fields": [],
    "allowed_actions": [
      "read",
      "search",
      "get",
      "create_index",
      "kibana_all_read"
    ]
  }],
  "tenant_permissions": [{
    "tenant_patterns": [
    "*"
    ],
    "allowed_actions": [
    "kibana_all_read"
    ]
  }]
}
'

curl -sS -u "${ES_DOMAIN_USER}:${ES_DOMAIN_PASSWORD}" \
    -X PATCH \
    https://${ES_ENDPOINT}/_opendistro/_security/api/rolesmapping/all_access?pretty \
    -H 'Content-Type: application/json' \
    -d'
[
  {
    "op": "add", "path": "/backend_roles", "value": ["'arn:aws:iam::AWS-account:role/*'","'arn:aws:iam::AWS-account:role/Cognito_kibana_accessAuth_admin'"]
  }
]
'

curl -sS -u "${ES_DOMAIN_USER}:${ES_DOMAIN_PASSWORD}" \
    -X PATCH \
    https://${ES_ENDPOINT}/_opendistro/_security/api/rolesmapping/all_access?pretty \
    -H 'Content-Type: application/json' \
    -d'
[
  {
    "op": "add", "path": "/users", "value": ["'test'","'arn:aws:iam::AWS-account:role/UnwireAdminRole'"]
  }
]
'

curl -sS -u "${ES_DOMAIN_USER}:${ES_DOMAIN_PASSWORD}" \
    -X PUT \
    https://${ES_ENDPOINT}/_opendistro/_security/api/rolesmapping/dev?pretty \
    -H 'Content-Type: application/json' \
    -d'
{
  "backend_roles" : [ "arn:aws:iam::AWS-account:role/Cognito_kibana_accessAuth_dev" ],
  "hosts" : [ "" ],
  "users" : [ "" ]
}
'
