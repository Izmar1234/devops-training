module "network" {
  source = "./modules/network"

  vpc_id              = var.existing_vpc_id
  internet_gateway_id = var.existing_internet_gateway_id
  nat_gateway_id      = var.existing_nat_gateway_id

  availability_zone   = var.availability_zone
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr

  name_prefix = local.name_prefix
}
