# Интеграция с CI/CD и удалённым хранением состояния

Решение описывает Terraform root-конфигурацию, GitLab CI pipeline и bootstrap-код для удалённого хранения состояния в Yandex Object Storage.

## Что реализовано

- `bootstrap/` создаёт Yandex Object Storage bucket с versioning, service account и static access key для S3 backend.
- Основной root вызывает локальный модуль `modules/environment` и разворачивает `dev`, `stage` или `prod`.
- Remote state настроен через Terraform `backend "s3"` с Yandex endpoint `https://storage.yandexcloud.net`.
- State locking включён через `use_lockfile = true`; lock-файл создаётся рядом с `task2/<env>/terraform.tfstate`.
- GitLab CI выполняет `fmt`, `validate`, `plan` и ручной `apply`.

Каталог не хранит реальные credentials, `terraform.tfvars`, локальный state, plan-файлы или `.terraform/` в репозитории.

## Архитектурные основания

| Понятие | Как использовано |
|---|---|
| Terraform lifecycle | CI/CD выполняет `fmt`, `init`, `validate`, `plan` и ручной `apply`. |
| Remote state | State хранится в S3-compatible Yandex Object Storage bucket, а не в рабочем дереве. |
| State locking | `use_lockfile = true` включает блокировку рядом с объектом state. |
| Infrastructure as Code | Root-конфигурация и bootstrap описаны кодом, проверяются в pipeline и не требуют ручных изменений в облачной консоли. |

## Структура

```text
Task2Advanced/
  README.md
  .gitignore
  .gitlab-ci.yml
  backend.tf
  main.tf
  variables.tf
  outputs.tf
  versions.tf
  modules/
    environment/
      main.tf
      variables.tf
      outputs.tf
      versions.tf
  bootstrap/
    main.tf
    variables.tf
    outputs.tf
    versions.tf
```

## Bootstrap remote state

Backend Terraform не может создать bucket, в котором хранит собственное состояние, поэтому bucket создаётся отдельным root-модулем:

```bash
terraform -chdir=Task2Advanced/bootstrap init
terraform -chdir=Task2Advanced/bootstrap apply \
  -var="cloud_id=<cloud-id>" \
  -var="folder_id=<folder-id>" \
  -var="state_bucket_name=<globally-unique-bucket-name>"
```

После `apply` outputs надо сохранить как GitLab CI variables:

| GitLab CI variable | Значение | Тип |
|---|---|---|
| `YC_TOKEN` | OAuth token или IAM-compatible token для Yandex provider | Masked, protected |
| `YC_CLOUD_ID` | Yandex Cloud ID | Plain/protected |
| `YC_FOLDER_ID` | Yandex Cloud folder ID | Plain/protected |
| `YC_STORAGE_ACCESS_KEY` | `bootstrap` output `storage_access_key` | Masked, protected |
| `YC_STORAGE_SECRET_KEY` | `bootstrap` output `storage_secret_key` | Masked, protected |
| `TF_STATE_BUCKET` | `bootstrap` output `state_bucket_name` | Plain/protected |
| `SSH_PUBLIC_KEY` | Публичный SSH-ключ для VM metadata | Plain/protected |
| `TF_ENV` | `dev`, `stage` или `prod`; по умолчанию `dev` | Plain |

Bootstrap state остаётся локальным и не хранится в репозитории. Для production его можно отдельно перенести в защищённый backend.

## Main Terraform root

Основной root использует S3 backend:

- bucket передаётся в CI через `TF_STATE_BUCKET`;
- key вычисляется в CI как `task2/${TF_ENV}/terraform.tfstate`;
- S3 credentials передаются через `AWS_ACCESS_KEY_ID` и `AWS_SECRET_ACCESS_KEY`, заполненные из `YC_STORAGE_ACCESS_KEY` и `YC_STORAGE_SECRET_KEY`;
- секреты не передаются через `-backend-config`, чтобы не сохранять их в `.terraform/` и plan-файлах.

Локальный запуск после bootstrap:

```bash
export YC_TOKEN="<oauth-or-iam-token>"
export AWS_ACCESS_KEY_ID="<storage-access-key>"
export AWS_SECRET_ACCESS_KEY="<storage-secret-key>"
export AWS_EC2_METADATA_DISABLED=true

terraform -chdir=Task2Advanced init -reconfigure \
  -backend-config="bucket=<state-bucket>" \
  -backend-config="key=task2/dev/terraform.tfstate"

terraform -chdir=Task2Advanced plan \
  -var="cloud_id=<cloud-id>" \
  -var="folder_id=<folder-id>" \
  -var="environment=dev" \
  -var="ssh_public_key=<public-ssh-key>"
```

## GitLab CI/CD

В каталоге есть самостоятельный pipeline [.gitlab-ci.yml](.gitlab-ci.yml). Корневой CI-файл репозитория может подключать его через `include`.

Pipeline:

| Stage | Job | Поведение |
|---|---|---|
| `fmt` | `terraform_fmt` | Проверяет форматирование `Task2Advanced`. |
| `validate` | `terraform_validate_bootstrap` | Проверяет bootstrap root без remote backend. |
| `validate` | `terraform_validate` | Инициализирует S3 backend и валидирует основной root. |
| `plan` | `terraform_plan` | Создаёт `tfplan` и `tfplan.txt`, artifact живёт 1 час. |
| `apply` | `terraform_apply` | Ручной job только на default branch, использует plan artifact. |

`resource_group: terraform-${TF_ENV}` блокирует параллельные `apply` для одного окружения.

## Проверки

```bash
terraform fmt -check -recursive Task2Advanced
terraform -chdir=Task2Advanced/bootstrap init -backend=false
terraform -chdir=Task2Advanced/bootstrap validate
terraform -chdir=Task2Advanced init -backend=false
terraform -chdir=Task2Advanced validate
ruby -e 'require "psych"; Psych.load_file(".gitlab-ci.yml"); Psych.load_file("Task2Advanced/.gitlab-ci.yml")'
```
