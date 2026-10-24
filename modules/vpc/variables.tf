variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# AZs passed from the root configuration.
variable "availability_zones" {
  description = "Availability Zones for VPC subnets"
  type        = list(string)
}
