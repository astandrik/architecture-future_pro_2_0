output "state_bucket_name" {
  description = "Yandex Object Storage bucket name for Terraform state."
  value       = yandex_storage_bucket.terraform_state.bucket
}

output "state_key_prefix" {
  description = "State key prefix used by the main Terraform root module."
  value       = "task2"
}

output "service_account_id" {
  description = "Service account ID used for Terraform state access."
  value       = yandex_iam_service_account.terraform_state.id
}

output "storage_access_key" {
  description = "Set this value as masked GitLab CI variable YC_STORAGE_ACCESS_KEY."
  value       = yandex_iam_service_account_static_access_key.terraform_state.access_key
  sensitive   = true
}

output "storage_secret_key" {
  description = "Set this value as masked GitLab CI variable YC_STORAGE_SECRET_KEY."
  value       = yandex_iam_service_account_static_access_key.terraform_state.secret_key
  sensitive   = true
}
