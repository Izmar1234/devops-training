resource "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.techmind.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-subnet-public"
    Type = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = data.aws_vpc.techmind.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-subnet-private"
    Type = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.techmind.id

  tags = {
    Name = "${var.name_prefix}-route-table-public"
    Type = "public"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.techmind.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.techmind.id

  tags = {
    Name = "${var.name_prefix}-route-table-private"
    Type = "private"
  }
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = data.aws_nat_gateway.techmind.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}