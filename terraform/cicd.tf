resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = { Name = "GitHub OIDC Provider" }
}

resource "aws_iam_role" "frontend_deploy_role" {
  name = "media-app-frontend-deploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" : "repo:ODaniel99/MediApp:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "frontend_deploy_policy" {
  name = "media-app-frontend-deploy-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:PutObject", "s3:ListBucket", "s3:DeleteObject"],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.frontend_bucket.arn,
          "${aws_s3_bucket.frontend_bucket.arn}/*"
        ]
      },
      {
        Action   = "cloudfront:CreateInvalidation",
        Effect   = "Allow",
        Resource = aws_cloudfront_distribution.s3_distribution.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "frontend_deploy_attachment" {
  role       = aws_iam_role.frontend_deploy_role.name
  policy_arn = aws_iam_policy.frontend_deploy_policy.arn
}

resource "aws_iam_role" "backend_deploy_role" {
  name = "media-app-backend-deploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" : "repo:ODaniel99/MediApp:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "backend_deploy_policy" {
  name = "media-app-backend-deploy-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "autoscaling:StartInstanceRefresh",
      Effect   = "Allow",
      Resource = aws_autoscaling_group.backend.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backend_deploy_attachment" {
  role       = aws_iam_role.backend_deploy_role.name
  policy_arn = aws_iam_policy.backend_deploy_policy.arn
}
