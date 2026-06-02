cloud_id           = "replace-with-cloud-id"
folder_id          = "replace-with-folder-id"
project_name       = "future-2-0"
environment        = "prod"
zone               = "ru-central1-a"
instance_name      = "future-2-0-prod-vm"
platform_id        = "standard-v3"
image_family       = "ubuntu-2204-lts"
cores              = 4
memory             = 8
disk_size          = 50
disk_type          = "network-ssd"
subnet_id          = "replace-with-prod-subnet-id"
nat                = false
security_group_ids = []
ssh_user           = "ubuntu"
ssh_public_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFuture20TrainingPublicKey future-2-0@example.invalid"

labels = {
  cost_center = "production"
}
