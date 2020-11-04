#################
# Terraform v0.13 
#################

#Retrieve subnets from VPC dedicated for the Resolver Endpoint on Infra Account
data "aws_subnet_ids" "subnet_dns_ids" {
  provider = aws.dev
  vpc_id = local.vpc_dns_id
}

#Create the Resolver Endpoint on Infra Account
module r53_resolver_endpoint {
  providers = { aws = aws.dev }
  source = "./modules/r53_resolver_endpoint"
  tags  = local.tags
  resolver_subnet_ids = data.aws_subnet_ids.subnet_dns_ids.ids
  resolver_endpoint_vpc_id = local.vpc_dns_id
  public_dns_ip = "8.8.8.8" #for sec gp
}

#Create The Resolver Rules on Infra Account
module r53_resolver_rule {
  providers = { aws = aws.dev }
  source = "./modules/r53_resolver_rule"
  resolver_endpoint_id = module.r53_resolver_endpoint.resolver_endpoint_id
  rules = [
    local.rule_1
    # { 
    #   rule_name   = "abc-foo"
    #   domain_name = "abc.foo."
    #   ram_name    = "ram-abc-foo"
    #   vpc_ids     = ["vpc-a","vpc-b"]
    #   target_ip   = "8.8.8.8"
    #   sharing_rules_with  = local.account_ids
    # },
    # { 
    #   rule_name   = "bar-foo"
    #   domain_name = "bar.foo."
    #   ram_name    = "ram-bar-foo"
    #   vpc_ids     = []
    #   target_ip   = "8.8.8.8"
    #   sharing_rules_with  = local.account_ids
    # }
  ]
}

module r53_rules_fetch {
  source = "./modules/r53_rules_fetch"
  providers = { aws = aws.dev2 }
  ram_assoc = module.r53_resolver_rule.ram_resource_association
  pending_rams = module.r53_resolver_rule.pending_rams
}

# Associate the shared rules on a Customer Account
module r53_receiver_associate {
  source = "./modules/r53_receiver_associate"
  providers = { aws = aws.dev2 }
  sharedfwd_public_rule_ids = module.r53_rules_fetch.sharedfwd_public_rule_ids
  sharedfwd_public_rule_domain_names = module.r53_rules_fetch.sharedfwd_public_rule_domain_names
  rules_assoc = [
    local.rule_1_dev2_assoc
    # { 
    #   rule_name   = "abc-foo"
    #   domain_name = "abc.foo."
    #   vpc_ids     = ["vpc-c"]
    # }
  ]
}
