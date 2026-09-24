module "storage" {
  source = "./modules/storage"

  bucket_name_prefix = local.bucket_name_prefix
  name_prefix        = local.name_prefix
}
