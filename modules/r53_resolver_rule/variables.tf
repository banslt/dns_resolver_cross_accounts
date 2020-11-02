variable resolver_endpoint_id {
  type        = string
  description = "resolver id to convey requests to DNS server"
}

variable rules {
  default     = []
  description = "resolver rules"
  type        = list
}
