output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

# Expose networking outputs from the VPC module.
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private application subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# Show the IDs of our two web servers.
output "web_instance_ids" {
  description = "IDs of the private EC2 web servers"
  value       = aws_instance.web[*].id
}

# Show private IP addresses.
# Neither web server should receive a public IPv4 address.
output "web_private_ips" {
  description = "Private IP addresses of the web servers"
  value       = aws_instance.web[*].private_ip
}
