provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

locals {
  service_account_name = "${var.project_name}-${var.environment}-tf-state"
}

resource "yandex_iam_service_account" "terraform_state" {
  folder_id   = var.folder_id
  name        = local.service_account_name
  description = "Service account for Terraform remote state in Yandex Object Storage."
}

resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_state.id}"
}

resource "yandex_iam_service_account_static_access_key" "terraform_state" {
  service_account_id = yandex_iam_service_account.terraform_state.id
  description        = "Static access key for Terraform S3 backend."

  depends_on = [
    yandex_resourcemanager_folder_iam_member.storage_admin
  ]
}

resource "yandex_storage_bucket" "terraform_state" {
  bucket        = var.state_bucket_name
  folder_id     = var.folder_id
  force_destroy = var.force_destroy
  access_key    = yandex_iam_service_account_static_access_key.terraform_state.access_key
  secret_key    = yandex_iam_service_account_static_access_key.terraform_state.secret_key

  versioning {
    enabled = true
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.storage_admin
  ]
}
