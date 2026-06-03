output "instance_id" {
  description = "Created VM ID."
  value       = yandex_compute_instance.vm.id
}

output "instance_name" {
  description = "Created VM name."
  value       = yandex_compute_instance.vm.name
}

output "disk_id" {
  description = "Created attached boot disk ID."
  value       = yandex_compute_disk.vm.id
}

output "disk_name" {
  description = "Created attached boot disk name."
  value       = yandex_compute_disk.vm.name
}

output "subnet_id" {
  description = "Subnet ID used by the VM network interface."
  value       = var.subnet_id
}

output "internal_ip_address" {
  description = "Internal IPv4 address of the VM."
  value       = yandex_compute_instance.vm.network_interface[0].ip_address
}

output "external_ip_address" {
  description = "External IPv4 address of the VM if NAT is enabled."
  value       = try(yandex_compute_instance.vm.network_interface[0].nat_ip_address, null)
}

output "environment" {
  description = "Environment name."
  value       = var.environment
}

output "labels" {
  description = "Labels applied to module resources."
  value       = local.common_labels
}
