resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block[0]
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr_blocks[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_cidr_blocks[count.index]
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# NAT Gateways
resource "aws_eip" "nat_eip" {
  count  = length(var.availability_zones)
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.default_route
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.default_route
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

