# VPC resource for Kubernetes cluster
resource "aws_vpc" "k8svpc" {
  cidr_block = var.cidr_block 
  tags = {
    Name = "k8svpc"
  }
} 

# Private subnet 01 for internal workloads
resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.k8svpc.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]

  tags = {
    Name                              = "private-us-east-1a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/image-app"      = "owned"
  }
}
# Private subnet 02 for internal workloads
resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.k8svpc.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
 
  tags = {
    Name                              = "private-us-east-1b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/image-app"      = "owned"
  }
}

# Public subnet 01 for load balancers and NAT
resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.k8svpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name                         = "public-us-east-1a"
    "kubernetes.io/role/elb"     = "1" # Instructs Kubernetes to create public load balancer in these subnets
    "kubernetes.io/cluster/image-app" = "owned"
  }
}
# Public subnet 02 for load balancers and NAT
resource "aws_subnet" "public-us-east-1b" {
  vpc_id                  = aws_vpc.k8svpc.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name                         = "public-us-east-1b"
    "kubernetes.io/role/elb"     = "1" # Instructs Kubernetes to create public load balancer in these subnets
    "kubernetes.io/cluster/image-app" = "owned"
  }
} 

# Internet Gateway for public subnets
resource "aws_internet_gateway" "k8svpc-igw" {
  vpc_id = aws_vpc.k8svpc.id

  tags = {
    Name = "k8svpc-igw"
  }
} 

# Public route table for internet access
resource "aws_route_table" "k8svpc-public" {
  vpc_id = aws_vpc.k8svpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8svpc-igw.id
  } 
  tags = {
    Name = "k8svpc-public"
  }
  depends_on = [ aws_internet_gateway.k8svpc-igw] 
} 

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  tags = {
    Name = "nat"
  }
}

# NAT Gateway for private subnet internet access
resource "aws_nat_gateway" "k8s-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "k8s-nat"
  }

  depends_on = [aws_internet_gateway.k8svpc-igw]
} 

# Private route table for NAT access
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.k8svpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.k8s-nat.id
    }

  tags = {
    Name = "private"
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private-us-east-1a" {
  subnet_id      = aws_subnet.private-us-east-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id      = aws_subnet.private-us-east-1b.id
  route_table_id =  aws_route_table.private.id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.k8svpc-public.id
}

resource "aws_route_table_association" "public-us-east-1b" {
  subnet_id      = aws_subnet.public-us-east-1b.id
  route_table_id = aws_route_table.k8svpc-public.id
}