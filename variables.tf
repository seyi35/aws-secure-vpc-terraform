variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
  default     = "eu-central-1"
}

# Availability Zones used to distribute infrastructure.
# Two distinct AZs support the multi-AZ design.
variable "availability_zones" {
  description = "Availability Zones for the two subnet pairs"
  type        = list(string)

  default = [
    "eu-central-1a",
    "eu-central-1b"
  ]
}
