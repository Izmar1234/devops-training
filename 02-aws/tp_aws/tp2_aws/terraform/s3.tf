resource "aws_s3_bucket" "source" {
  bucket = local.source_bucket_name

  force_destroy = false

  tags = {
    Name = "${local.name_prefix}_s3_pdf_source"
    Role = "pdf-source"
  }
}

resource "aws_s3_bucket" "destination" {
  bucket = local.destination_bucket_name

  force_destroy = false

  tags = {
    Name = "${local.name_prefix}_s3_pdf_destination"
    Role = "pdf-destination"
  }
}

resource "aws_s3_bucket_ownership_controls" "source" {
  bucket = aws_s3_bucket.source.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "destination" {
  bucket = aws_s3_bucket.destination.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "source" {
  bucket = aws_s3_bucket.source.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "destination" {
  bucket = aws_s3_bucket.destination.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source" {
  bucket = aws_s3_bucket.source.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "destination" {
  bucket = aws_s3_bucket.destination.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "source" {
  bucket = aws_s3_bucket.source.id

  rule {
    id     = "delete-pdf-after-seven-days"
    status = "Enabled"

    filter {}

    expiration {
      days = var.expiration_days
    }
  }

  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.source
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "destination" {
  bucket = aws_s3_bucket.destination.id

  rule {
    id     = "delete-processed-pdf-after-seven-days"
    status = "Enabled"

    filter {}

    expiration {
      days = var.expiration_days
    }
  }

  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.destination
  ]
}

data "aws_iam_policy_document" "source_bucket_tls" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.source.arn,
      "${aws_s3_bucket.source.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "destination_bucket_tls" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.destination.arn,
      "${aws_s3_bucket.destination.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "source_tls" {
  bucket = aws_s3_bucket.source.id
  policy = data.aws_iam_policy_document.source_bucket_tls.json

  depends_on = [
    aws_s3_bucket_public_access_block.source
  ]
}

resource "aws_s3_bucket_policy" "destination_tls" {
  bucket = aws_s3_bucket.destination.id
  policy = data.aws_iam_policy_document.destination_bucket_tls.json

  depends_on = [
    aws_s3_bucket_public_access_block.destination
  ]
}
