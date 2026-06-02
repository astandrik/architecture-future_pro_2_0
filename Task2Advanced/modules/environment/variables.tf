variable "project_name" {
  description = "Short lowercase project prefix used in resource names and labels."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,38}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-40 lowercase Latin letters, digits, or hyphens, start with a letter, and not end with a hyphen."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, stage, prod."
  }
}

variable "folder_id" {
  description = "Yandex Cloud folder ID where resources will be created."
  type        = string

  validation {
    condition     = length(trimspace(var.folder_id)) > 0
    error_message = "folder_id must not be empty."
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

variable "subnet_cidr" {
  description = "IPv4 CIDR block for the environment subnet."
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid IPv4 CIDR block."
  }
}

variable "instance_name" {
  description = "Optional VM name. If omitted, the module builds a name from project_name and environment."
  type        = string
  default     = null

  validation {
    condition     = var.instance_name == null || can(regex("^[a-z][a-z0-9-]{1,61}[a-z0-9]$", var.instance_name))
    error_message = "instance_name must be null or 3-63 lowercase Latin letters, digits, or hyphens, start with a letter, and not end with a hyphen."
  }
}

variable "platform_id" {
  description = "Yandex Compute Cloud platform ID."
  type        = string
  default     = "standard-v3"
}

variable "image_family" {
  description = "Public image family used for the VM boot disk."
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "cores" {
  description = "Number of vCPU cores for the VM."
  type        = number

  validation {
    condition     = var.cores > 0
    error_message = "cores must be greater than 0."
  }
}

variable "memory" {
  description = "RAM size in GB for the VM."
  type        = number

  validation {
    condition     = var.memory > 0
    error_message = "memory must be greater than 0."
  }
}

variable "disk_size" {
  description = "Boot disk size in GB."
  type        = number

  validation {
    condition     = var.disk_size >= 10
    error_message = "disk_size must be at least 10 GB."
  }
}

variable "disk_type" {
  description = "Boot disk type."
  type        = string
  default     = "network-ssd"
}

variable "nat" {
  description = "Whether to assign a public NAT address to the VM."
  type        = bool
  default     = false
}

variable "ssh_user" {
  description = "Linux user that receives the public SSH key."
  type        = string
  default     = "ubuntu"

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]*[$]?$", var.ssh_user))
    error_message = "ssh_user must be a valid Linux username."
  }
}

variable "ssh_public_key" {
  description = "Public SSH key to place into VM metadata. Do not pass private keys."
  type        = string

  validation {
    condition     = can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256) .+", trimspace(var.ssh_public_key)))
    error_message = "ssh_public_key must be a public SSH key starting with ssh-rsa, ssh-ed25519, or ecdsa-sha2-nistp256."
  }
}

variable "allowed_ssh_cidrs" {
  description = "IPv4 CIDR blocks allowed to connect to SSH."
  type        = list(string)

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
  description = "Additional Yandex Cloud labels to merge with module labels."
  type        = map(string)
  default     = {}
}
