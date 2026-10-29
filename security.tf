# --------------------------------------------------
# APPLICATION LOAD BALANCER SECURITY GROUP
# Accepts public HTTP traffic on port 80.
# --------------------------------------------------

resource "aws_security_group" "alb" {
  name_prefix = "secure-vpc-alb-"
  description = "Security group for public ALB"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "secure-vpc-alb-sg"
  }
}

# Allow website visitors to reach the ALB.
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# The ALB only needs to forward HTTP traffic to web servers.
resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}


# --------------------------------------------------
# PRIVATE WEB SERVER SECURITY GROUP
# Only the ALB can initiate HTTP connections.
# --------------------------------------------------

resource "aws_security_group" "web" {
  name_prefix = "secure-vpc-web-"
  description = "Security group for private web instances"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "secure-vpc-web-sg"
  }
}

# Reference the ALB Security Group instead of allowing
# traffic from every IP address on the internet.
resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# Allow outbound traffic so Ubuntu can download packages
# through the NAT Gateway in the private subnet route table.
resource "aws_vpc_security_group_egress_rule" "web_outbound" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

