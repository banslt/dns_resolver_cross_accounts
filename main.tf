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

module r53_resolver_rule {
  providers = { aws = aws.dev }
  source = "./modules/r53_resolver_rule"
  resolver_endpoint_id = module.r53_resolver_endpoint.resolver_endpoint_id
  rules = [
    { rule_name   = "rule1"
      domain_name = "abc.foo."
      ram_name    = "ram-rule1"
      vpc_ids     = local.vpc_ids
      target_ip   = "8.8.8.8"
      sharing_rules_with  = local.account_ids
    },
    { rule_name   = "rule2"
      domain_name = "bar.foo."
      ram_name    = "ram-rule2"
      vpc_ids     = local.vpc_ids
      target_ip   = "8.8.8.8"
      sharing_rules_with  = local.account_ids
    }
  ]
}
