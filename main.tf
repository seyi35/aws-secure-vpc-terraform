module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = "172.20.0.0/16"
  availability_zones = var.availability_zones
}
