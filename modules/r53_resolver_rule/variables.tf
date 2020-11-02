variable resolver_endpoint_id {
  type        = string
  description = "resolver id to convey requests to DNS server"
}

variable rules {
  default     = []
  description = "resolver rules"
  type        = list
}

# {     rule_name   = "rule-a"
#       domain_name = "dev.foo."
#       ram_name    = "ram-rule-a"
#       vpc_ids     = [""]
#       target_ip   = 8.8.8.8
#       sharing_rules_with  = ["123456789101", "123456789102"]
# }