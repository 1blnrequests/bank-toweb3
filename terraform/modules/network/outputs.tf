locals {
  public_subnet_ids = [for name, subnet in aws_subnet.this : subnet.id if subnet.map_public_ip_on_launch]
  private_subnet_ids = [for name, subnet in aws_subnet.this : subnet.id if subnet.map_public_ip_on_launch == false]
}

output "vpc_id" {
  description = "Identifier of the created VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = local.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = local.private_subnet_ids
}
