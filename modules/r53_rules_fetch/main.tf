#Approve shared rules
resource "aws_ram_resource_share_accepter" "shared_rules_accept" {
  count     = length(var.pending_rams)
  share_arn = element(var.pending_rams, count.index)
}

#Looking for the shared rules on a Customer Account
data "aws_route53_resolver_rules" "shared_rule_list" {
  rule_type    = "FORWARD"
  share_status = "SHARED_WITH_ME"
  depends_on = [aws_ram_resource_share_accepter.shared_rules_accept]
}

data "aws_route53_resolver_rule" "shared_rule" {
  count            = length(var.pending_rams)
  resolver_rule_id = element(sort(data.aws_route53_resolver_rules.shared_rule_list.resolver_rule_ids),count.index)
}
