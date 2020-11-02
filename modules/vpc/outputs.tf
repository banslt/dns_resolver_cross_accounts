output vpc_id {
  value       = aws_vpc.vpc.id
  description = "VPC ID"
}

output subnet_id {
  value       = aws_subnet.subnet.id
  description = "subnet ID"
}
