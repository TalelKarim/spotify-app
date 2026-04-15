resource "aws_lambda_layer_version" "python_requests" {
  layer_name          = "python-requests-aws4auth"
  compatible_runtimes = ["python3.12"]

  filename         = "../../../app/lambdas/layers/python-requests-aws4auth.zip"
  source_code_hash = filebase64sha256("../../../app/lambdas/layers/python-requests-aws4auth.zip")

  description = "Requests + requests-aws4auth for OpenSearch access"
}

resource "aws_lambda_layer_version" "shared_logger" {
  layer_name          = "${var.project_name}-shared-logger"
  compatible_runtimes = ["python3.12"]

  filename         = "../../../app/lambdas/layers/shared-python.zip"
  source_code_hash = filebase64sha256("../../../app/lambdas/layers/shared-python.zip")

  description = "Shared structured logger for Python Lambdas"
}



resource "aws_lambda_layer_version" "python_mutagen" {
  layer_name          = "${var.project_name}-python-mutagen"
  filename            = "../../../app/lambdas/layers/mutagen.zip"
  compatible_runtimes = ["python3.12"]

  source_code_hash = filebase64sha256("../../../app/lambdas/layers/mutagen.zip")
}
