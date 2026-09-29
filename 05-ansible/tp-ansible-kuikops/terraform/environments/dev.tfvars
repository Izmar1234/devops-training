project_name = "tp-ansible"
environment  = "dev"
owner        = "izmar-abderrahim"

name_prefix = "tech-mind-izmar-abderrahim-tp-ansible"

availability_zone = "eu-west-3a"

vpc_id              = "vpc-02855c98755e6b058"
internet_gateway_id = "igw-0fed3cfd38607d94b"
nat_gateway_id      = "nat-1522f5fbe634d3413"

public_subnet_cidr  = "10.0.20.0/24"
private_subnet_cidr = "10.0.21.0/24"

admin_cidr = "176.124.41.245/32"

ssh_public_key_path = "~/.ssh/tp_ansible_kuikops.pub"

front_01_instance_type = "t3.small"
front_02_instance_type = "t3.micro"
glpi_app_instance_type = "t3.small"
glpi_db_instance_type  = "t3.micro"

root_volume_size = 12
web_volume_size  = 5
logs_volume_size = 5