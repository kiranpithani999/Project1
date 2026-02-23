variable "vpc_cidr" {}
variable "public_subnet_cidrs" { type = list(string) }
variable "public_subnet_azs"   { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "private_subnet_azs"   { type = list(string) }
variable "common_tags" { type = map(string) }