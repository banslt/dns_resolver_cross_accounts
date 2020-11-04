output sharedfwd_public_rule_ids {
  value       = data.aws_route53_resolver_rule.shared_rule.*.resolver_rule_id
  description = "shared resolver rule ids"
}

output sharedfwd_public_rule_domain_names {
  value       = data.aws_route53_resolver_rule.shared_rule.*.domain_name
  description = "shared resolver domain names"
}
