output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "lambda_name" {
  value = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.this.arn
}



output "lambda_version" {
  value = aws_lambda_function.this.version
}

output "lambda_alias_name" {
  value = try(aws_lambda_alias.this[0].name, null)
}


output "lambda_alias_arn" {
  value = try(aws_lambda_alias.this[0].arn, null)
}

output "lambda_alias_invoke_arn" {
  value = try(aws_lambda_alias.this[0].invoke_arn, null)
}

