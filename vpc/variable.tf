variable "vpc_cidr" {
  default = "10.1.0.0/16"
}
variable "tenancy" {
  default = "dedicated"
}
#variable "vpc_id" {}

variable "subnet_cidr" {
  type="list"
  default=["10.1.0.0/24","10.1.1.0/24","10.1.2.0/24"]
}


variable "subnetpub_cidr" {
  default="10.1.3.0/24"
}
#variable "subnet_id" {}

#variable "subnet_id1" {}
