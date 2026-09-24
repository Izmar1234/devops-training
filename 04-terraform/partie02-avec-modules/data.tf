
data "aws_caller_identity" "current" {}



data "aws_vpc" "existing" {
  id = var.existing_vpc_id
}



data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = (
    "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  )
}



data "aws_iam_instance_profile" "ssm" {
  name = var.ssm_instance_profile_name
}
