terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.130.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

module "vm_module" {
  source = "../../modules/vm"

  project_name       = var.project_name
  environment        = var.environment
  folder_id          = var.folder_id
  zone               = var.zone
  instance_name      = var.instance_name
  platform_id        = var.platform_id
  image_family       = var.image_family
  cores              = var.cores
  memory             = var.memory
  disk_size          = var.disk_size
  disk_type          = var.disk_type
  subnet_id          = var.subnet_id
  nat                = var.nat
  security_group_ids = var.security_group_ids
  ssh_user           = var.ssh_user
  ssh_public_key     = var.ssh_public_key
  labels             = var.labels
}
