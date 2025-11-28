# ---------------------------------------------
# Variables
# ---------------------------------------------
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain" {
  type = string
}

variable "elb_name" {
  type = string
}

variable "s3_bucket_regional_domain_name" {
  type = string
}

variable "s3_bucket_id" {
  type = string
}

variable "virginia_cert" {
  type = string
}

variable "zone_id" {
  type = string
}