module "security" {
  source = "./modules/security"

  vpc_id           = var.existing_vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr

  ssh_public_key = file(
    pathexpand(var.ssh_public_key_path)
  )

  name_prefix = local.name_prefix
}
