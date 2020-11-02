variable tags {
  default     = {}
  description = "Tags to apply to resources"
  type        = map(string)
}

variable cidr_block {
  type        = string
#   default     = "172.22.0.0/27"
  description = "VPC cidr block"
}
