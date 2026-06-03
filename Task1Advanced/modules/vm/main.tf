locals {
  common_labels = merge(
    {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.labels
  )

  resource_prefix = "${var.project_name}-${var.environment}"
  instance_name   = var.instance_name == null ? "${local.resource_prefix}-vm" : var.instance_name
}

data "yandex_compute_image" "os" {
  family = var.image_family
}

resource "yandex_compute_disk" "vm" {
  folder_id   = var.folder_id
  name        = "${local.resource_prefix}-disk"
  description = "Attached boot disk for ${local.instance_name}"
  type        = var.disk_type
  zone        = var.zone
  size        = var.disk_size
  image_id    = data.yandex_compute_image.os.id
  labels      = local.common_labels
}

resource "yandex_compute_instance" "vm" {
  folder_id                 = var.folder_id
  name                      = local.instance_name
  hostname                  = local.instance_name
  description               = "VM for ${var.project_name} ${var.environment}"
  platform_id               = var.platform_id
  zone                      = var.zone
  allow_stopping_for_update = true
  labels                    = local.common_labels

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    disk_id     = yandex_compute_disk.vm.id
    auto_delete = false
  }

  network_interface {
    subnet_id          = var.subnet_id
    nat                = var.nat
    security_group_ids = var.security_group_ids
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${trimspace(var.ssh_public_key)}"
  }
}
