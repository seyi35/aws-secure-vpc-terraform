resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "secure-vpc"
  }
}

# --------------------------------------------------
# PUBLIC SUBNETS
# One subnet in each Availability Zone.
# Internet routing will be added in the next phase.
# --------------------------------------------------

resource "aws_subnet" "public_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.20.1.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "public-subnet-az1"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.20.2.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "public-subnet-az2"
  }
}


# --------------------------------------------------
# PRIVATE APPLICATION SUBNETS
# These will host EC2 instances without public IPs.
# Outbound routing will be configured later.
# --------------------------------------------------

resource "aws_subnet" "private_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.20.11.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-az1"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.20.12.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-az2"
  }
}

# --------------------------------------------------
# INTERNET GATEWAY
# Provides a path between the VPC and the internet.
# Public subnets will use it through their route table.
# --------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "secure-vpc-igw"
  }
} # --------------------------------------------------
# PUBLIC ROUTE TABLE
# Shared by both public subnets across AZ1 and AZ2.
# --------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

# Send internet-bound IPv4 traffic to the IGW.
# The VPC's local route is added automatically by AWS.

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# --------------------------------------------------
# PUBLIC SUBNET ASSOCIATIONS
# Both public subnets use the public route table.
# --------------------------------------------------

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

# --------------------------------------------------
# PRIVATE ROUTE TABLE
# No internet default route is defined yet.
# NAT Gateway routing will be added next milestone.
# --------------------------------------------------

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

# --------------------------------------------------
# PRIVATE SUBNET ASSOCIATIONS
# Associate both private subnets with this route table.
# --------------------------------------------------

resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private_az2.id
  route_table_id = aws_route_table.private.id
}


# --------------------------------------------------
# NAT GATEWAY - OUTBOUND INTERNET FOR PRIVATE SUBNETS
# --------------------------------------------------

# Allocate a static public IPv4 address for the NAT Gateway.
# AWS uses this Elastic IP for outbound internet traffic.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "secure-vpc-nat-eip"
  }
}

# Deploy one public NAT Gateway in AZ1.
# Both private subnets will use it for outbound internet.
# This saves lab costs but creates an AZ1 dependency.
resource "aws_nat_gateway" "main" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = aws_subnet.public_az1.id
  connectivity_type = "public"
  availability_mode = "zonal"

  # Ensure the Internet Gateway exists before creating NAT.
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "secure-vpc-nat"
  }
}

# --------------------------------------------------
# PRIVATE INTERNET ROUTE
# --------------------------------------------------

# Send internet-bound traffic from both private subnets
# through NAT instead of directly through the Internet Gateway.
resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
