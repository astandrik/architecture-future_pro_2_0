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

resource "yandex_vpc_network" "this" {
  folder_id   = var.folder_id
  name        = "${local.resource_prefix}-network"
  description = "Network for ${var.project_name} ${var.environment}"
  labels      = local.common_labels
}

resource "yandex_vpc_subnet" "this" {
  folder_id      = var.folder_id
  name           = "${local.resource_prefix}-subnet"
  description    = "Subnet for ${var.project_name} ${var.environment}"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.subnet_cidr]
  labels         = local.common_labels
}

resource "yandex_vpc_security_group" "this" {
  folder_id   = var.folder_id
  name        = "${local.resource_prefix}-sg"
  description = "Security group for ${var.project_name} ${var.environment}"
  network_id  = yandex_vpc_network.this.id
  labels      = local.common_labels

  ingress {
    description    = "SSH access"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = var.allowed_ssh_cidrs
  }

  dynamic "ingress" {
    for_each = toset(var.allowed_ingress_ports)

    content {
      description    = "Application port ${ingress.value}"
      protocol       = "TCP"
      port           = ingress.value
      v4_cidr_blocks = var.allowed_app_cidrs
    }
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_disk" "boot" {
  folder_id   = var.folder_id
  name        = "${local.resource_prefix}-boot-disk"
  description = "Boot disk for ${local.instance_name}"
  type        = var.disk_type
  zone        = var.zone
  size        = var.disk_size
  image_id    = data.yandex_compute_image.os.id
  labels      = local.common_labels
}

resource "yandex_compute_instance" "this" {
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
    disk_id     = yandex_compute_disk.boot.id
    auto_delete = false
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.this.id
    nat                = var.nat
    security_group_ids = [yandex_vpc_security_group.this.id]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${trimspace(var.ssh_public_key)}"
  }
}
