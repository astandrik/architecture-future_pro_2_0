output "instance_id" {
  description = "Prod VM ID."
  value       = module.vm_module.instance_id
}

output "instance_name" {
  description = "Prod VM name."
  value       = module.vm_module.instance_name
}

output "disk_id" {
  description = "Prod attached boot disk ID."
  value       = module.vm_module.disk_id
}

output "internal_ip_address" {
  description = "Prod VM internal IPv4 address."
  value       = module.vm_module.internal_ip_address
}

output "external_ip_address" {
  description = "Prod VM external IPv4 address if NAT is enabled."
  value       = module.vm_module.external_ip_address
}
