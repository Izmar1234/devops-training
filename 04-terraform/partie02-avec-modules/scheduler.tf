module "scheduler" {
  source = "./modules/scheduler"

  providers = {
    aws                      = aws
    aws.without_default_tags = aws.without_default_tags
    archive                  = archive
  }

  name_prefix = local.name_prefix
  owner       = local.owner

  docker_instance_id  = module.compute.docker_instance_id
  docker_instance_arn = module.compute.docker_instance_arn

  nodejs_instance_id  = module.compute.nodejs_instance_id
  nodejs_instance_arn = module.compute.nodejs_instance_arn

  lambda_source_file = (
    "${path.module}/lambda/scheduler.py"
  )

  lambda_output_path = (
    "${path.module}/lambda/scheduler.zip"
  )
}
