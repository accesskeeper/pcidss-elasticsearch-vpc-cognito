```
Elasticsearch with Cognito authentication deployed inside VPC which is compliant with PCIDSS. There is a 2 roles deployed for admin and developer to access different kind of log streams. It is possible to add more users for example security staff.
2 factor Authentication configured with phone SMS. so please provide your number when you will create new user in cognito.
This setup could be used for payment and health data.
```

## ElasticSearch setup

#### How to deploy

1. Define variables in es_vpc/terraform.tfvars
1. Run 'terraform apply' - This will setup VPC, Elasticsearch cluster and IAM roles
1. At the end of terraform apply you will see a **CLIENTID**, which can look like this: '6dqf1vc4p6fgidbq19guv6bqqs', outputted to a file called **clientid.tmp** - This will be needed for next step which is cognito terraform state.
```
Outputs:

cognito_role_arn = arn:aws:iam::AWS-ACCOUNT:role/Cognito_kibana_accessAuth_admin
identity_pool_id = eu-west-1:dfed0b5b-0508-4037-953b-db6570cf8c2d
user_pool_id = eu-west-1_ivtqfdqM8

$ cat clientid.tmp
nsil3bp07sjeslhffd6qcnfts
```
1. Go to **part2** folder which is located at same folder level as **part1** and edit 'main.tf'
1. Make sure you are conneted to either VPN or using SSHShuttle as part of this setup involves hitting endpoints inside VPC that arent public accessible.
1. You will need to find this section and paste in the new clientid generated from the step above 
```
locals {
  identity_pool        = "kibana2_access"
  clientid             = "<INSERT CLIENTID HERE>"
}
```
6. Run 'terraform apply' to setup cognito integration.
7. After all this has been completed you can access elasticsearch by getting the URL from AWS Console - ElasticSearch - Remember to be connected to VPN when accessing it.

#### Adding users

Before you can login to ElasticSearch you need to add yourself as user in AWS Cognito and add that user to a group.

For now we use the AWS Console, but this step could be added to cognito terraform step in the future.

1. Go to AWS console and then Cognito and choose **User pools*
1. Choose user pool **kibana2_access**
1. Choose **Users and groups**
1. Click on **Create user** and fill in the form
1. Click on the user you just created and choose **Add to group** in the top.
1. Add to the correct group by using the dropdown menu.


