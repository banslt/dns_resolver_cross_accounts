resource "aws_route53_resolver_rule" "fwd_public_rule" {
    count                = length(local.rules)
    rule_type            = "FORWARD"
    resolver_endpoint_id = var.resolver_endpoint_id

    domain_name          = lookup(element(local.rules, count.index), "domain_name", null)
    name                 = lookup(element(local.rules, count.index), "rule_name", null)
    target_ip {
        ip               = lookup(element(local.rules, count.index), "target_ip", null)
    }

}

resource "aws_route53_resolver_rule_association" "r53_rule_association" {
    count            = length(local.vpcs_associations)
    resolver_rule_id = element(aws_route53_resolver_rule.fwd_public_rule.*.id,
        index(aws_route53_resolver_rule.fwd_public_rule.*.domain_name, 
              lookup(element(local.vpcs_associations, count.index),
              "domain_name")
    ))
    vpc_id = lookup(element(local.vpcs_associations, count.index), "vpc_id")
    depends_on = [aws_route53_resolver_rule.fwd_public_rule]
}

resource "aws_ram_resource_share" "rule_share" {
  count                     = length(local.rules)
  name                      = lookup(element(local.rules, count.index), "ram_name")
  allow_external_principals = false
}

resource "aws_ram_principal_association" "rule_ram_principal_assoc" {
  count              = length(local.ram_associations)
  principal          = lookup(element(local.ram_associations, count.index), "principal_id")
  resource_share_arn = element(aws_ram_resource_share.rule_share.*.arn,
    index(aws_ram_resource_share.rule_share.*.name,
          lookup(element(local.ram_associations, count.index),  "ram_name")
  ))
  depends_on = [aws_ram_resource_share.rule_share]
}

resource "aws_ram_resource_association" "rule_ram_resource_assoc" {
  count        = length(local.rules)
  # we need to remove the last "." here because domain_name 
  # is not stored with last "." in rule for some reason...
  resource_arn = element(aws_route53_resolver_rule.fwd_public_rule.*.arn,
    index(aws_route53_resolver_rule.fwd_public_rule.*.domain_name, 
          trimsuffix(lookup(element(local.rules, count.index), "domain_name"),".")
  ))
  resource_share_arn = aws_ram_resource_share.rule_share[count.index].arn
  depends_on         = [aws_route53_resolver_rule.fwd_public_rule]
}

locals {
    #Allowing us to perform nested loops for associations.

    rules = [
        for rule in var.rules : {
        rule_name   = lookup(rule, "rule_name", null)
        domain_name = lookup(rule, "domain_name", null)
        ram_name    = lookup(rule, "ram_name", null)
        vpc_ids     = lookup(rule, "vpc_ids", [])
        target_ip   = lookup(rule, "target_ip", null)
        sharing_rules_with  = lookup(rule, "sharing_rules_with", [])
        }
    ]

    vpcs_associations = flatten([
        for rule in var.rules : [
            for vpc in lookup(rule, "vpc_ids") : {
                vpc_id      = vpc
                domain_name = lookup(rule, "domain_name")
            }
        ]
    ])

    ram_associations = flatten([
        for rule in var.rules : [
            for principal in lookup(rule, "sharing_rules_with") : {
                principal_id = principal
                ram_name     = lookup(rule, "ram_name", lookup(rule, "domain_name"))
            }
        ]
    ])
}
