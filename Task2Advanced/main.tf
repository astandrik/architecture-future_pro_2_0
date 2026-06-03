provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

locals {
  environment_settings = {
    dev = {
      subnet_cidr = "10.10.1.0/24"
      cores       = 2
      memory      = 2
      disk_size   = 15
      cost_center = "sandbox"
    }
    stage = {
      subnet_cidr = "10.10.2.0/24"
      cores       = 2
      memory      = 4
      disk_size   = 25
      cost_center = "preprod"
    }
    prod = {
      subnet_cidr = "10.10.3.0/24"
      cores       = 4
      memory      = 8
      disk_size   = 50
      cost_center = "production"
    }
  }

  selected_environment = local.environment_settings[var.environment]
}

module "environment" {
  source = "./modules/environment"

  project_name          = var.project_name
  environment           = var.environment
  folder_id             = var.folder_id
  zone                  = var.zone
  subnet_cidr           = local.selected_environment.subnet_cidr
  instance_name         = "${var.project_name}-${var.environment}-vm"
  cores                 = local.selected_environment.cores
  memory                = local.selected_environment.memory
  disk_size             = local.selected_environment.disk_size
  nat                   = false
  ssh_public_key        = var.ssh_public_key
  allowed_ssh_cidrs     = var.allowed_ssh_cidrs
  allowed_app_cidrs     = var.allowed_app_cidrs
  allowed_ingress_ports = var.allowed_ingress_ports

  labels = merge(
    var.labels,
    {
      cost_center = local.selected_environment.cost_center
      task        = "task2"
    }
  )
}
