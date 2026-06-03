variable "cloud_id" {
  description = "Yandex Cloud ID. Prefer a local tfvars override or YC_CLOUD_ID in real runs."
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID. Prefer a local tfvars override or YC_FOLDER_ID in real runs."
  type        = string
}

variable "project_name" {
  description = "Short lowercase project prefix used in resource names and labels."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "zone" {
  description = "Yandex Cloud availability zone."
  type        = string
}

variable "instance_name" {
  description = "VM name."
  type        = string
}

variable "platform_id" {
  description = "Yandex Compute Cloud platform ID."
  type        = string
}

variable "image_family" {
  description = "Public image family used for the VM boot disk."
  type        = string
}

variable "cores" {
  description = "Number of vCPU cores for the VM."
  type        = number
}

variable "memory" {
  description = "RAM size in GB for the VM."
  type        = number
}

variable "disk_size" {
  description = "Attached boot disk size in GB."
  type        = number
}

variable "disk_type" {
  description = "Attached boot disk type."
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID for the VM network interface."
  type        = string
}

variable "nat" {
  description = "Whether to assign a public NAT address to the VM."
  type        = bool
}

variable "security_group_ids" {
  description = "Optional security group IDs to attach to the VM network interface."
  type        = list(string)
}

variable "ssh_user" {
  description = "Linux user that receives the public SSH key."
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key for VM metadata."
  type        = string
}

variable "labels" {
  description = "Additional Yandex Cloud labels to merge with module labels."
  type        = map(string)
}
