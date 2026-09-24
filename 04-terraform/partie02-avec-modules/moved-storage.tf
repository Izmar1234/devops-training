moved {
  from = aws_s3_bucket.first
  to   = module.storage.aws_s3_bucket.first
}

moved {
  from = aws_s3_bucket.second
  to   = module.storage.aws_s3_bucket.second
}

moved {
  from = aws_s3_bucket_ownership_controls.first
  to   = module.storage.aws_s3_bucket_ownership_controls.first
}

moved {
  from = aws_s3_bucket_ownership_controls.second
  to   = module.storage.aws_s3_bucket_ownership_controls.second
}

moved {
  from = aws_s3_bucket_public_access_block.first
  to   = module.storage.aws_s3_bucket_public_access_block.first
}

moved {
  from = aws_s3_bucket_public_access_block.second
  to   = module.storage.aws_s3_bucket_public_access_block.second
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.first
  to   = module.storage.aws_s3_bucket_server_side_encryption_configuration.first
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.second
  to   = module.storage.aws_s3_bucket_server_side_encryption_configuration.second
}

moved {
  from = data.aws_iam_policy_document.first_bucket_tls
  to   = module.storage.data.aws_iam_policy_document.first_bucket_tls
}

moved {
  from = data.aws_iam_policy_document.second_bucket_tls
  to   = module.storage.data.aws_iam_policy_document.second_bucket_tls
}

moved {
  from = aws_s3_bucket_policy.first_tls
  to   = module.storage.aws_s3_bucket_policy.first_tls
}

moved {
  from = aws_s3_bucket_policy.second_tls
  to   = module.storage.aws_s3_bucket_policy.second_tls
}
