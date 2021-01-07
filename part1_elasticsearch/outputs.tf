output "user_pool_id" {
  description = "The ID of the user_pool"
  value       = aws_cognito_user_pool.kibana_user_pool.id
}

output "identity_pool_id" {
  description = "The ID of the identity_pool"
  value       = aws_cognito_identity_pool.kibana_identity_pool.id
}

output "cognito_role_arn" {
  description = "The ARN of the cognito role"
  value       = aws_iam_role.cognito_auth_role.arn
}

