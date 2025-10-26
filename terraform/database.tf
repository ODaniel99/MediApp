resource "aws_iam_service_linked_role" "dynamodb_replication" {
  aws_service_name = "dynamodb.application-autoscaling.amazonaws.com"
}

resource "aws_dynamodb_table" "main" {
  name         = "media-app-data-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  replica {
    region_name = var.aws_replica_region
  }

  tags = {
    Name = "media-app-data-table"
  }

  depends_on = [
    aws_iam_service_linked_role.dynamodb_replication
  ]
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids = [aws_route_table.private.id]
  tags            = { Name = "media-app-dynamodb-endpoint" }
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "media-app-dynamodb-access-policy"
  role = aws_iam_role.backend_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem",
        "dynamodb:DeleteItem", "dynamodb:Query", "dynamodb:Scan"
      ],
      Effect = "Allow",

      Resource = "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.main.name}"
    }]
  })
}
