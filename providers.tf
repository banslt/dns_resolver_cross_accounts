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
