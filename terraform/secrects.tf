resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "media-app/application-secrets"
  description = "Placeholder for application-level secrets for the Media App."

  tags = {
    Name = "media-app-app-secrets"
  }
}

resource "aws_iam_role_policy" "secrets_manager_access" {
  name = "media-app-secrets-manager-access-policy"
  role = aws_iam_role.backend_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue"
      ],
      Effect   = "Allow",
      Resource = aws_secretsmanager_secret.app_secrets.arn
    }]
  })
}
