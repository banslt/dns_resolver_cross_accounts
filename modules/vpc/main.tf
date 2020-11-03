resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
    tags = var.tags
}

resource "aws_subnet" "subnet" {
    count = 2
    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index)
    tags = var.tags
}
