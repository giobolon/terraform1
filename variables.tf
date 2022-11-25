variable "region_a" {
  type    = string
  default = "ap-southeast-2a"
}

variable "region_b" {
  type    = string
  default = "ap-southeast-2b"
}

variable "region_c" {
  type    = string
  default = "ap-southeast-2c"
}

variable "req_tags" {
  description = "Skillup required tags"
  type        = map(string)
  default = {
    "GBL_CLASS_0" = "SERVICE"
    "GBL_CLASS_1" = "TEST"
  }
}

variable "ami_id" {
  type    = string
  default = "ami-055166f8a8041fbf1"
}

variable "my_home_ip" {
  type    = string
  default = "112.201.105.205/32"
}

variable "iam_user" {
  type    = string
  default = "skillup-j.bolon-readonly"
}

variable "key_name" {
  type    = string
  default = "skillup-j.bolon-pem"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "nametag" {
  type    = string
  default = "skillup-j.bolon-web"
}