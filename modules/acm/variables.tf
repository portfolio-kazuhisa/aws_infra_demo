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
  type = string
}

variable "zone_id" {
  type = string
}

variable "host_zone" {
  type = object({
    id      = string
    name    = string
    zone_id = optional(string) # 必要な属性だけ指定してOK
  })
}
