output "network_id" {
  description = "Created VPC network ID."
  value       = yandex_vpc_network.this.id
}

output "subnet_id" {
  description = "Created subnet ID."
  value       = yandex_vpc_subnet.this.id
}

output "security_group_id" {
  description = "Created security group ID."
  value       = yandex_vpc_security_group.this.id
}

output "instance_id" {
  description = "Created compute instance ID."
  value       = yandex_compute_instance.this.id
}

output "instance_name" {
  description = "Created compute instance name."
  value       = yandex_compute_instance.this.name
}

output "internal_ip_address" {
  description = "Internal IPv4 address of the instance."
  value       = yandex_compute_instance.this.network_interface[0].ip_address
}

output "external_ip_address" {
  description = "External IPv4 address of the instance if NAT is enabled."
  value       = try(yandex_compute_instance.this.network_interface[0].nat_ip_address, null)
}

output "environment" {
  description = "Environment name."
  value       = var.environment
}

output "labels" {
  description = "Labels applied to module resources."
  value       = local.common_labels
}
