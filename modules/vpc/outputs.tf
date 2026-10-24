output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# Public subnets used later by the Application Load Balancer.
output "public_subnet_ids" {
  description = "IDs of the two public subnets"

  value = [
    aws_subnet.public_az1.id,
    aws_subnet.public_az2.id
  ]
}

# Private subnets used later by the EC2 instances.
output "private_subnet_ids" {
  description = "IDs of the two private application subnets"

  value = [
    aws_subnet.private_az1.id,
    aws_subnet.private_az2.id
  ]
}
