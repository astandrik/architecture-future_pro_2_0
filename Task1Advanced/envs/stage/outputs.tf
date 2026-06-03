output "instance_id" {
  description = "Stage VM ID."
  value       = module.vm_module.instance_id
}

output "instance_name" {
  description = "Stage VM name."
  value       = module.vm_module.instance_name
}

output "disk_id" {
  description = "Stage attached boot disk ID."
  value       = module.vm_module.disk_id
}

output "internal_ip_address" {
  description = "Stage VM internal IPv4 address."
  value       = module.vm_module.internal_ip_address
}

output "external_ip_address" {
  description = "Stage VM external IPv4 address if NAT is enabled."
  value       = module.vm_module.external_ip_address
}
