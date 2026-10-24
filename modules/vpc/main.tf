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
