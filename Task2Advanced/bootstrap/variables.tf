variable "cloud_id" {
  description = "Yandex Cloud ID."
  type        = string

  validation {
    condition     = length(trimspace(var.cloud_id)) > 0
    error_message = "cloud_id must not be empty."
  }
}

variable "folder_id" {
  description = "Yandex Cloud folder ID where the state bucket and service account are created."
  type        = string

  validation {
    condition     = length(trimspace(var.folder_id)) > 0
    error_message = "folder_id must not be empty."
  }
}

variable "project_name" {
  description = "Short lowercase project prefix used in bootstrap resource names."
  type        = string
  default     = "future-2-0"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,38}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-40 lowercase Latin letters, digits, or hyphens, start with a letter, and not end with a hyphen."
  }
}

variable "environment" {
  description = "Bootstrap environment suffix."
  type        = string
  default     = "shared"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.environment))
    error_message = "environment must be 3-32 lowercase Latin letters, digits, or hyphens, start with a letter, and not end with a hyphen."
  }
}

variable "zone" {
  description = "Default Yandex Cloud availability zone."
  type        = string
  default     = "ru-central1-a"

  validation {
    condition     = can(regex("^ru-central1-[a-d]$", var.zone))
    error_message = "zone must look like ru-central1-a, ru-central1-b, ru-central1-c, or ru-central1-d."
  }
}

variable "state_bucket_name" {
  description = "Globally unique Yandex Object Storage bucket name for Terraform state."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be 3-63 lowercase letters, digits, dots, or hyphens, and start/end with a letter or digit."
  }
}

variable "force_destroy" {
  description = "Allow Terraform to delete the state bucket even when it contains objects. Keep false outside disposable smoke tests."
  type        = bool
  default     = false
}
