# ---------------------------------------------
# Variables
# ---------------------------------------------
variable "project" {
  type = string
}

variable "DomainName" {
  type = string
}

variable "environment" {
  type = string
}

variable "elb" {
  type = object({
    dns_name = string
    zone_id  = string
  })
}

