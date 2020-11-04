output ram_resource_association {
  value       = aws_ram_resource_association.rule_ram_resource_assoc
  description = "description"
}

output pending_rams {
  value       = aws_ram_principal_association.rule_ram_principal_assoc.*.resource_share_arn
  description = "pending rules ram arns"
}
