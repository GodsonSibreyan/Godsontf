module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = format("%s-vpc", var.name)
  azs = var.vpc_azs
  cidr = var.vpc_cidr

  public_subnets = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets
  database_subnets = var.vpc_database_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az

  tags = {
    Group = var.name
  } 
}

# Borrowed from VPC Module from Terraform Module Repository:
variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  default     = ["10.0.0.0/16"]
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = [["10.0.1.0/24", "10.0.2.0/24"]]
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = [["10.0.11.0/24", "10.0.12.0/24"]]
}

variable "vpc_database_subnets" {
  description = "A list of database subnets"
  default     = [["10.0.21.0/24", "10.0.22.0/24"]]
}

variable "vpc_azs" {
  description = "A list of availability zones in the region"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c","us-east-1d","us-east-1e","us-east-1f"]
}

variable "vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = false
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "vpc_one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  default     = false
}
