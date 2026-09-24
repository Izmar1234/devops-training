module "compute" {
  source = "./modules/compute"

  ami_id           = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type    = var.instance_type
  root_volume_size = var.root_volume_size

  public_subnet_id  = module.network.public_subnet_id
  private_subnet_id = module.network.private_subnet_id

  public_security_group_id  = module.security.public_security_group_id
  private_security_group_id = module.security.private_security_group_id

  key_pair_name             = module.security.key_pair_name
  iam_instance_profile_name = data.aws_iam_instance_profile.ssm.name

  docker_user_data = file(
    "${path.module}/user-data/docker.sh"
  )

  nodejs_user_data = file(
    "${path.module}/user-data/nodejs.sh"
  )

  name_prefix = local.name_prefix

  depends_on = [
    module.network
  ]
}
