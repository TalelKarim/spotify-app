resource "aws_lambda_layer_version" "python_requests" {
  layer_name          = "python-requests-aws4auth"
  compatible_runtimes = ["python3.12"]

  filename         = "../../../app/lambdas/layers/python-requests-aws4auth.zip"
  source_code_hash = filebase64sha256("../../../app/lambdas/layers/python-requests-aws4auth.zip")

  description = "Requests + requests-aws4auth for OpenSearch access"
}
