# ---------------------------------------------
# Variables
# ---------------------------------------------
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "web_sg_id" {
  type = string
}

variable "subnet_id_1a" {
  type = string
}

variable "subnet_id_1c" {
  type = string
}

variable "target_ec2_id" {
  type = string
}

variable "tokyo_cert_arn" {
  type = string
}
