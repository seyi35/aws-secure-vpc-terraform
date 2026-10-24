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
