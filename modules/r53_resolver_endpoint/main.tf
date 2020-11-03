resource "aws_route53_resolver_endpoint" "resolver_endpoint" {
    direction = "OUTBOUND"
    tags = var.tags

    security_group_ids = [
        aws_security_group.resolver_endpoint_sg.id
    ]
    # Need at least 2 ip_adress blocks
    ip_address {
        subnet_id = var.resolver_subnet_id[0]
    }

    ip_address {
        subnet_id = var.resolver_subnet_id[1]
    }
}

resource "aws_security_group" "resolver_endpoint_sg" {
  name_prefix = "r53-endpoint-"
  vpc_id      = var.resolver_endpoint_vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "resolver_endpoint_sg_rule" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "all"
  cidr_blocks       = ["${var.public_dns_ip}/32"]
  security_group_id = aws_security_group.resolver_endpoint_sg.id
}
