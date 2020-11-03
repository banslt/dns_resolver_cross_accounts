variable resolver_subnet_id {
  type        = list
  description = "resolver subnet IDs"
}

variable resolver_endpoint_vpc_id {
  type        = string
  description = "resolver VPC ID"
}

variable tags {
  default     = {}
  description = "Tags to apply to resources"
  type        = map(string)
}

variable public_dns_ip {
  type        = string
  description = "description"
}
