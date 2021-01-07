1. REQUIRE VPN CONNECTION to EXECUTE
2. cat ../es_vpc/clientid.tmp
3. paste this  clientd in main.tf local variables
example:  "clientid             = "2633uhbltmvl7eugt7rg79nhcn""
#this is something we have to improve, for some reason i was not able to read clientid.tmp by terraform and take as input variable. (also we can't pass it as output variable because this id we don't create with TF)
4. terraform init, terraform apply
5. Navigate to Cognito and see "Users and Groups" tab. please add users and add them to the respective groups.
#we can add users for cognito with tf, in same way as we have it for IAM.
