# ---------------------------------------------
# Variables
# ---------------------------------------------
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "DomainName" {
  type = string
}

variable "validation_method" {
  type = enum
}

variable "lifecycle" {
  type = string
}

variable "route53_zone" {
  type = object({
    route53_zone = string
  })
}