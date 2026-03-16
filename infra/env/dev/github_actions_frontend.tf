data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "github_actions_frontend_assume_role" {
  statement {
    sid    = "GitHubActionsAssumeRole"
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

resource "aws_iam_role" "github_actions_frontend_deploy" {
  name               = "${var.project_name}-github-actions-frontend-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_actions_frontend_assume_role.json
}

data "aws_iam_policy_document" "github_actions_frontend_deploy_policy" {
  statement {
    sid    = "ListFrontendBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      module.frontend.bucket_arn
    ]
  }

  statement {
    sid    = "WriteFrontendObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${module.frontend.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "InvalidateFrontendCloudFront"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      module.frontend.cloudfront_arn
    ]
  }
}

resource "aws_iam_policy" "github_actions_frontend_deploy" {
  name   = "${var.project_name}-github-actions-frontend-deploy"
  policy = data.aws_iam_policy_document.github_actions_frontend_deploy_policy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_frontend_deploy" {
  role       = aws_iam_role.github_actions_frontend_deploy.name
  policy_arn = aws_iam_policy.github_actions_frontend_deploy.arn
}