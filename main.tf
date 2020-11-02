provider "aws" {
    region = "us-east-1"
    alias = "dev"
    profile = local.cross_account_profile_name
    assume_role {
        role_arn = local.aws_dev_devops_std_role
        session_name = local.session_name
    }
}

provider "aws" {
    region = "us-east-1"
    alias = "dev2"
    profile = local.cross_account_profile_name
    assume_role {
        role_arn = local.aws_dev2_devops_std_role
        session_name = local.session_name
    }
}

#Create a VPC dedicated for the Resolver Endpoint on Infra Account
module vpc {
  providers = { aws = aws.dev }
  source = "./modules/vpc"
  tags  = local.tags
  cidr_block = "172.22.0.0/27"
}

#Create the Resolver Endpoint on Infra Account
module r53_resolver_endpoint {
  providers = { aws = aws.dev }
  source = "./modules/r53_resolver_endpoint"
  tags  = local.tags
  resolver_subnet_id = module.vpc.vpc_id
  resolver_endpoint_vpc_id = module.vpc.subnet_id
  public_dns_ip = "8.8.8.8"
}

#Create The Resolver Rules on Infra Account
module r53_resolver_rule {
  providers = { aws = aws.dev }
  source = "./modules/r53_resolver_rule"
  resolver_endpoint_id = module.r53_resolver_endpoint.resolver_endpoint_id
  rules = [
    { 
      rule_name   = "abc-foo"
      domain_name = "abc.foo."
      ram_name    = "ram-abc-foo"
      vpc_ids     = local.vpc_ids
      target_ip   = "8.8.8.8"
      sharing_rules_with  = local.account_ids
    },
    { 
      rule_name   = "bar-foo"
      domain_name = "bar.foo."
      ram_name    = "ram-bar-foo"
      vpc_ids     = []
      target_ip   = "8.8.8.8"
      sharing_rules_with  = local.account_ids
    }
  ]
}

#Looking for the shared rules on Customer Account
data "aws_route53_resolver_rules" "shared_rule_list" {
  provider     = aws.dev2
  rule_type    = "FORWARD"
  share_status = "SHARED_WITH_ME"
  depends_on   = [module.r53_resolver_rule.ram_resource_association] 
}

data "aws_route53_resolver_rule" "shared_rule" {
  count        = length(data.aws_route53_resolver_rules.shared_rule_list)
  provider     = aws.dev2
  resolver_rule_id = element(data.aws_route53_resolver_rules.shared_rule_list.*.id,count.index)
}

# Associate the rules on Customer Account
module r53_receiver_associate {
  source = "./modules/r53_receiver_associate"
  providers = { aws = aws.dev2 }
  sharedfwd_public_rule_ids = data.aws_route53_resolver_rules.shared_rule_list.*.id
  sharedfwd_public_rule_domain_names = data.aws_route53_resolver_rule.shared_rule.*.domain_name
  rules = [
    { 
      rule_name   = "abc-foo"
      domain_name = "abc.foo."
      vpc_ids     = local.vpc_ids
    },
    { 
      rule_name   = "bar-foo"
      domain_name = "bar.foo."
      vpc_ids     = []
    }
  ]
}
