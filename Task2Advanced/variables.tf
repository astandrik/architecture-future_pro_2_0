variable "cloud_id" {
  description = "Yandex Cloud ID. In CI set TF_VAR_cloud_id from YC_CLOUD_ID."
  type        = string

  validation {
    condition     = length(trimspace(var.cloud_id)) > 0
    error_message = "cloud_id must not be empty."
  }
}

variable "folder_id" {
  description = "Yandex Cloud folder ID. In CI set TF_VAR_folder_id from YC_FOLDER_ID."
  type        = string

  validation {
    condition     = length(trimspace(var.folder_id)) > 0
    error_message = "folder_id must not be empty."
  }
}

variable "project_name" {
  description = "Short lowercase project prefix used in resource names and labels."
  type        = string
  default     = "future-2-0"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,38}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-40 lowercase Latin letters, digits, or hyphens, start with a letter, and not end with a hyphen."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, stage, prod."
  }
}

variable "zone" {
  description = "Yandex Cloud availability zone."
  type        = string
  default     = "ru-central1-a"

  validation {
    condition     = can(regex("^ru-central1-[a-d]$", var.zone))
    error_message = "zone must look like ru-central1-a, ru-central1-b, ru-central1-c, or ru-central1-d."
  }
}

variable "ssh_public_key" {
  description = "Public SSH key for VM metadata. In CI set TF_VAR_ssh_public_key from SSH_PUBLIC_KEY."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256) .+", trimspace(var.ssh_public_key)))
    error_message = "ssh_public_key must be a public SSH key starting with ssh-rsa, ssh-ed25519, or ecdsa-sha2-nistp256."
  }
}

variable "allowed_ssh_cidrs" {
  description = "IPv4 CIDR blocks allowed to connect to SSH."
  type        = list(string)
  default     = ["10.0.0.0/8"]

  validation {
    condition     = length(var.allowed_ssh_cidrs) > 0 && alltrue([for cidr in var.allowed_ssh_cidrs : can(cidrhost(cidr, 0))])
    error_message = "allowed_ssh_cidrs must contain at least one valid IPv4 CIDR block."
  }
}

variable "allowed_app_cidrs" {
  description = "IPv4 CIDR blocks allowed to connect to application ingress ports."
  type        = list(string)
  default     = ["10.0.0.0/8"]

  validation {
    condition     = length(var.allowed_app_cidrs) > 0 && alltrue([for cidr in var.allowed_app_cidrs : can(cidrhost(cidr, 0))])
    error_message = "allowed_app_cidrs must contain at least one valid IPv4 CIDR block."
  }
}

variable "allowed_ingress_ports" {
  description = "Application TCP ports opened by the security group."
  type        = list(number)
  default     = [80, 443]

  validation {
    condition     = alltrue([for port in var.allowed_ingress_ports : port >= 1 && port <= 65535])
    error_message = "allowed_ingress_ports values must be in the 1-65535 range."
  }
}

variable "labels" {
  description = "Additional labels to merge with environment labels."
  type        = map(string)
  default     = {}
}
