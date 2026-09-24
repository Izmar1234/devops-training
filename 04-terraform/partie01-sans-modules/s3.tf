# ============================================================
# DEUX BUCKETS S3 SANS USAGE APPLICATIF
# ============================================================

resource "aws_s3_bucket" "first" {
  bucket = "${local.bucket_name_prefix}-bucket-one"

  # Empêche terraform destroy de supprimer un bucket contenant
  # encore des objets.
  force_destroy = false

  tags = {
    Name = "${local.name_prefix}_s3_bucket_one"
    Role = "general-storage-one"
  }
}


resource "aws_s3_bucket" "second" {
  bucket = "${local.bucket_name_prefix}-bucket-two"

  force_destroy = false

  tags = {
    Name = "${local.name_prefix}_s3_bucket_two"
    Role = "general-storage-two"
  }
}


# ============================================================
# PROPRIÉTÉ DES OBJETS
# ============================================================

resource "aws_s3_bucket_ownership_controls" "first" {
  bucket = aws_s3_bucket.first.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


resource "aws_s3_bucket_ownership_controls" "second" {
  bucket = aws_s3_bucket.second.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


# ============================================================
# BLOCAGE DE TOUT ACCÈS PUBLIC
# ============================================================

resource "aws_s3_bucket_public_access_block" "first" {
  bucket = aws_s3_bucket.first.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_public_access_block" "second" {
  bucket = aws_s3_bucket.second.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


# ============================================================
# CHIFFREMENT AU REPOS
# ============================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "first" {
  bucket = aws_s3_bucket.first.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "second" {
  bucket = aws_s3_bucket.second.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# ============================================================
# CHIFFREMENT EN TRANSIT : REFUSER HTTP
# ============================================================

data "aws_iam_policy_document" "first_bucket_tls" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.first.arn,
      "${aws_s3_bucket.first.arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}


data "aws_iam_policy_document" "second_bucket_tls" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.second.arn,
      "${aws_s3_bucket.second.arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}


resource "aws_s3_bucket_policy" "first_tls" {
  bucket = aws_s3_bucket.first.id
  policy = data.aws_iam_policy_document.first_bucket_tls.json

  depends_on = [
    aws_s3_bucket_public_access_block.first
  ]
}


resource "aws_s3_bucket_policy" "second_tls" {
  bucket = aws_s3_bucket.second.id
  policy = data.aws_iam_policy_document.second_bucket_tls.json

  depends_on = [
    aws_s3_bucket_public_access_block.second
  ]
}
