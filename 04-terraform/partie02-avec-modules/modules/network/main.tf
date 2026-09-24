# ============================================================
# SUBNET PUBLIC
# ============================================================

resource "aws_subnet" "public" {
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}_subnet_public"
    Type = "public"
  }
}


# ============================================================
# SUBNET PRIVÉ
# ============================================================

resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}_subnet_private"
    Type = "private"
  }
}


# ============================================================
# TABLE DE ROUTAGE PUBLIQUE
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}_rt_public"
    Type = "public"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# ============================================================
# TABLE DE ROUTAGE PRIVÉE
# ============================================================

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}_rt_private"
    Type = "private"
  }
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

