# ---------------------------------------------
# Variables
# ---------------------------------------------
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id_1a" {
  type = string
}

variable "subnet_id_1c" {
  type = string
}

variable "app_sg_id" {
  type = string
}

variable "mng_sg_id" {
  type = string
}

variable "ec2_profile" {
  type = string
}

variable "target_group_arn" {
  type = string
}

