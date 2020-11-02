resource "aws_route53_resolver_rule_association" "r53_rule_association" {
    count            = length(local.vpcs_associations)
    # we need to remove the last "." here because domain_name 
    # is not stored with last "." in rule for some reason...
    resolver_rule_id = element(var.sharedfwd_public_rule_ids,
        index(var.sharedfwd_public_rule_domain_names, 
              trimsuffix(lookup(element(local.vpcs_associations, count.index),
              "domain_name"),".")
    ))
    vpc_id = lookup(element(local.vpcs_associations, count.index), "vpc_id")
}

locals {
    #Allowing us to perform nested loops for associations.

    vpcs_associations = flatten([
        for rule in var.rules : [
            for vpc in lookup(rule, "vpc_ids") : {
                vpc_id      = vpc
                domain_name = lookup(rule, "domain_name")
            }
        ]
    ])
}
