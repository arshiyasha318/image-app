resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.image-vpc
  }
}
resource "aws_subnet" "public" {
   cidr_block                = var.public_subnet_cidrs
    vpc_id                    = aws_vpc.main.id
    map_public_ip_on_launch   = true
    availability_zone         = data.aws_availability_zones.available.names[0]
    tags = {
      Name = var.subnet_public
    }
}

resource "aws_subnet" "private" {
  cidr_block        = var.private_subnet_cidrs
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
 tags = {
    Name = var.subnet_private
  }
 }
 


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
    tags = {
        Name = var.internet_gateway
    }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
    tags = {
        Name = var.Route-table
    }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

data "aws_availability_zones" "available" {
  state = "available"
}

