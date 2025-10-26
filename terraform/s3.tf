resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "media_bucket" {
  bucket = "media-app-user-media-${random_id.bucket_suffix.hex}"
  tags   = { Name = "media-app-media-bucket" }
}

resource "aws_s3_bucket_versioning" "media_bucket_versioning" {
  bucket = aws_s3_bucket.media_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media_bucket_encryption" {
  bucket = aws_s3_bucket.media_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "media_bucket_pab" {
  bucket = aws_s3_bucket.media_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "media-app-frontend-${random_id.bucket_suffix.hex}"
  tags   = { Name = "media-app-frontend-bucket" }
}

resource "aws_s3_bucket_versioning" "frontend_bucket_versioning" {
  bucket = aws_s3_bucket.frontend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role_policy" "s3_media_access" {
  name = "media-app-s3-media-access-policy"
  role = aws_iam_role.backend_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      Effect   = "Allow",
      Resource = "${aws_s3_bucket.media_bucket.arn}/*"
    }]
  })
}

resource "aws_s3_bucket" "media_bucket_replica" {
  provider = aws.replica
  bucket   = "${aws_s3_bucket.media_bucket.id}-replica"
}

resource "aws_s3_bucket_versioning" "media_bucket_replica_versioning" {
  provider = aws.replica
  bucket   = aws_s3_bucket.media_bucket_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "frontend_bucket_replica" {
  provider = aws.replica
  bucket   = "${aws_s3_bucket.frontend_bucket.id}-replica"
}

resource "aws_s3_bucket_versioning" "frontend_bucket_replica_versioning" {
  provider = aws.replica
  bucket   = aws_s3_bucket.frontend_bucket_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "s3_replication_role" {
  name = "media-app-s3-replication-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "s3.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "s3_replication_policy" {
  name = "media-app-s3-replication-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:GetReplicationConfiguration", "s3:ListBucket"],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.media_bucket.arn,
          aws_s3_bucket.frontend_bucket.arn,
        ]
      },
      {
        Action = ["s3:GetObjectVersionForReplication", "s3:GetObjectVersionAcl", "s3:GetObjectVersionTagging"],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.media_bucket.arn}/*",
          "${aws_s3_bucket.frontend_bucket.arn}/*",
        ]
      },
      {
        Action = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.media_bucket_replica.arn}/*",
          "${aws_s3_bucket.frontend_bucket_replica.arn}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_replication_attachment" {
  role       = aws_iam_role.s3_replication_role.name
  policy_arn = aws_iam_policy.s3_replication_policy.arn
}

resource "aws_s3_bucket_replication_configuration" "media_bucket_replication" {
  depends_on = [aws_iam_role_policy_attachment.s3_replication_attachment]
  role       = aws_iam_role.s3_replication_role.arn
  bucket     = aws_s3_bucket.media_bucket.id

  rule {
    id     = "replicate-all"
    status = "Enabled"
    destination {
      bucket = aws_s3_bucket.media_bucket_replica.arn
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "frontend_bucket_replication" {
  depends_on = [aws_iam_role_policy_attachment.s3_replication_attachment]
  role       = aws_iam_role.s3_replication_role.arn
  bucket     = aws_s3_bucket.frontend_bucket.id

  rule {
    id     = "replicate-all"
    status = "Enabled"
    destination {
      bucket = aws_s3_bucket.frontend_bucket_replica.arn
    }
  }
}
