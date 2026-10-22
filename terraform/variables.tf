variable "vpc_cidr" {
  type    = string
  default = "10.125.0.0/16"
}

variable "public1_cidr" {
  type = string
  default = "10.125.1.0/24"
}

variable "public2_cidr" {
  type = string
  default = "10.125.2.0/24"
}

variable "ssh_cidr" {
  type = string
  default = "103.174.26.110/32"
}