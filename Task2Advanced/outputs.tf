output "network_id" {
  description = "Created VPC network ID."
  value       = module.environment.network_id
}

output "subnet_id" {
  description = "Created subnet ID."
  value       = module.environment.subnet_id
}

output "security_group_id" {
  description = "Created security group ID."
  value       = module.environment.security_group_id
}

output "instance_id" {
  description = "Created compute instance ID."
  value       = module.environment.instance_id
}

output "instance_name" {
  description = "Created compute instance name."
  value       = module.environment.instance_name
}

output "internal_ip_address" {
  description = "Internal IPv4 address of the instance."
  value       = module.environment.internal_ip_address
}

output "external_ip_address" {
  description = "External IPv4 address of the instance if NAT is enabled."
  value       = module.environment.external_ip_address
}

output "environment" {
  description = "Environment name."
  value       = module.environment.environment
}

output "labels" {
  description = "Labels applied to module resources."
  value       = module.environment.labels
}
