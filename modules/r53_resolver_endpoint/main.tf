resource "aws_route53_resolver_endpoint" "resolver_endpoint" {
    direction = "OUTBOUND"
    name = "sre3053"
    tags = var.tags

    security_group_ids = [
        aws_security_group.resolver_endpoint_sg.id
    ]

    dynamic "ip_address" {
      for_each = var.resolver_subnet_ids
      content {
        subnet_id = ip_address.value
      }
    }
}

resource "aws_security_group" "resolver_endpoint_sg" {
  name_prefix = "sre3053-r53-endpoint-"
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
  cidr_blocks       = [var.allow_outbound_ip, "10.0.0.0/8"]
  security_group_id = aws_security_group.resolver_endpoint_sg.id
}
