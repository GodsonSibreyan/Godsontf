variable "active_key" {
    description = "AccessKey"
    default     = "user"
}

variable "security_key" {
    description = "Secretkey"
    default     = "password"
}
variable "region" {
  description = "The AWS region to deploy to"
  default = "us-east-1"
}

variable "name" {
  description = "The name of the deployment"
  default = "djangothreetier"
}

variable "public_key" {
  default = "godsnv"
}
variable "image" {
  default = "ami-0323c3dd2da7fb37d"
}
variable "size" {
  default = "10"
}
variable "instance_type" {
  default = "t2.micro"
}

