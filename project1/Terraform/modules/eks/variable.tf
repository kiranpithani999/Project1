variable "cluster_name" {}
variable "subnet_ids" { type = list(string) }
variable "desired_size" {}
variable "min_size" {}
variable "max_size" {}