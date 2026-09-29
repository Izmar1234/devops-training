data "aws_vpc" "techmind" {
  id = var.vpc_id
}

data "aws_internet_gateway" "techmind" {
  filter {
    name   = "internet-gateway-id"
    values = [var.internet_gateway_id]
  }

  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.techmind.id]
  }
}

data "aws_nat_gateway" "techmind" {
  id = var.nat_gateway_id

  lifecycle {
    postcondition {
      condition = (
        self.vpc_id == data.aws_vpc.techmind.id &&
        self.state == "available"
      )

      error_message = "Le NAT Gateway doit appartenir au VPC du TP et être disponible."
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}