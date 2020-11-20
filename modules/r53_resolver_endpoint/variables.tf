variable resolver_subnet_ids {
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

variable allow_outbound_ip {
  type        = string
  description = "outbound IP range SecGrp for Endpoint"
}

variable direction {
  type        = string
  default     = "OUTBOUND"
  description = "Endpoint Direction"
}
