# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = { "Name" = "${var.project_name}-vpc" }
}

# Public Subnet
resource "aws_subnet" "public" {
  count             = var.availability_zone_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = [for cidr_block in cidrsubnets(var.cidr_block, 2, 2) : cidrsubnets(cidr_block, 2, 2, 2)][0][count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { "Name" = "${var.project_name}-public-subnet-${format("%02d", "${count.index}" + 1)}" }
}

# Private Subnet
resource "aws_subnet" "private" {
  count             = var.availability_zone_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = [for cidr_block in cidrsubnets(var.cidr_block, 2, 2) : cidrsubnets(cidr_block, 2, 2, 2)][1][count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { "Name" = "${var.project_name}-private-subnet-${format("%02d", "${count.index}" + 1)}" }
}

# Intenet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { "Name" = "${var.project_name}-igw" }
}

# EIP for NAT Gateway
resource "aws_eip" "nat_eip" {
  count = var.availability_zone_count
  vpc   = true

  tags       = { "Name" = "${var.project_name}-nat-eip-${format("%02d", "${count.index}" + 1)}" }
  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  count         = var.availability_zone_count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags       = { "Name" = "${var.project_name}-nat-${format("%02d", "${count.index}" + 1)}" }
  depends_on = [aws_eip.nat_eip]
}

# Public Route Table
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { "Name" = "${var.project_name}-public-rt" }
}

# Public Route Table Association
resource "aws_route_table_association" "pub_rt_assc" {
  count          = var.availability_zone_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.pub_rt.id

  depends_on = [aws_route_table.pub_rt]
}

# Private Route Table
resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.main.id

  tags = { "Name" = "${var.project_name}-private-rt" }
}

# Private Route
resource "aws_route" "priv_route" {
  route_table_id         = aws_route_table.priv_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id

  depends_on = [aws_nat_gateway.nat_gw, aws_route_table.priv_rt]
}

# Private Route Table Association
resource "aws_route_table_association" "priv_rt_assc" {
  count          = var.availability_zone_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.priv_rt.id

  depends_on = [aws_route_table.priv_rt]
}
