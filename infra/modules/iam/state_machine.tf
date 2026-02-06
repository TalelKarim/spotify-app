resource "aws_iam_role" "step_functions" {
  name = "${var.project_name}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "step_functions_invoke_lambdas" {
  name = "${var.project_name}-step-functions-invoke-lambdas"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "lambda:InvokeFunction"
      Resource = var.orchestration_lambda_arns
    }]
  })
}


resource "aws_iam_role_policy_attachment" "step_functions_invoke_lambdas" {
  role       = aws_iam_role.step_functions.name
  policy_arn = aws_iam_policy.step_functions_invoke_lambdas.arn
}
