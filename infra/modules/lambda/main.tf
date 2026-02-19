resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.role_arn
  handler       = var.handler
  runtime       = var.runtime

  filename         = var.package_path
  source_code_hash = filebase64sha256(var.package_path)

  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = var.layers


  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 && length(var.security_group_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

}
