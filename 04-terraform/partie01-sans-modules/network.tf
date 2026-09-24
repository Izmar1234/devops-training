# ============================================================
# SUBNET PUBLIC
# ============================================================

resource "aws_subnet" "public" {
  vpc_id            = var.existing_vpc_id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone

  # Les EC2 créées dans ce subnet peuvent recevoir
  # automatiquement une adresse IPv4 publique.
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}_subnet_public"
    Type = "public"
  }
}


# ============================================================
# SUBNET PRIVÉ
# ============================================================

resource "aws_subnet" "private" {
  vpc_id            = var.existing_vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  # Une EC2 privée ne doit pas recevoir d'adresse IP publique.
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}_subnet_private"
    Type = "private"
  }
}


# ============================================================
# TABLE DE ROUTAGE PUBLIQUE
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = var.existing_vpc_id

  tags = {
    Name = "${local.name_prefix}_rt_public"
    Type = "public"
  }
}


# Route par défaut vers l'Internet Gateway existante.
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.existing_internet_gateway_id
}


# Association entre le subnet public et sa table de routage.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# ============================================================
# TABLE DE ROUTAGE PRIVÉE
# ============================================================

resource "aws_route_table" "private" {
  vpc_id = var.existing_vpc_id

  tags = {
    Name = "${local.name_prefix}_rt_private"
    Type = "private"
  }
}


# Route sortante du subnet privé vers le NAT Gateway existant.
resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.existing_nat_gateway_id
}


# Association entre le subnet privé et sa table de routage.
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
