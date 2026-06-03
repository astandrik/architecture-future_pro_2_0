# Модульная инфраструктура для нескольких сред

Решение описывает переиспользуемый Terraform-модуль `vm_module` для создания VM в Yandex Cloud и три окружения: `dev`, `stage`, `prod`.

## Что реализовано

Модуль `modules/vm` создаёт:

- подключаемый boot disk на базе публичного образа ОС;
- compute instance;
- сетевой интерфейс VM в переданной subnet;
- SSH-доступ через public key в metadata.

Модуль не создаёт VPC/subnet: по требованиям задания `subnet_id` передаётся входным параметром. Поэтому один и тот же модуль подходит для разных сетевых контуров и окружений.

## Архитектурные основания

| Понятие | Как использовано |
|---|---|
| Infrastructure as Code | Инфраструктура описана декларативными `.tf`-конфигурациями, которые можно проверять и версионировать. |
| Terraform provider | Провайдер Yandex Cloud создаёт VM и disk, а сетевой интерфейс подключает VM к существующей subnet. |
| Terraform state | State не хранится в репозитории; локальные `.tfstate`, `.terraform/` и plan-файлы исключены через `.gitignore`. |
| Несколько сред | `dev`, `stage` и `prod` используют один модуль `modules/vm`, но получают разные параметры через собственные `.tfvars`. |

## Структура

```text
Task1Advanced/
  README.md
  modules/
    vm/
      main.tf
      variables.tf
      outputs.tf
      versions.tf
  envs/
    dev/
      main.tf
      variables.tf
      outputs.tf
      dev.tfvars
    stage/
      main.tf
      variables.tf
      outputs.tf
      stage.tfvars
    prod/
      main.tf
      variables.tf
      outputs.tf
      prod.tfvars
```

## Матрица окружений

| Environment | Назначение | CPU | RAM | Disk | NAT | tfvars |
|---|---|---:|---:|---:|---|---|
| `dev` | Sandbox для пилотов | 2 | 2 GB | 15 GB | `false` | `envs/dev/dev.tfvars` |
| `stage` | Интеграционные и pre-production проверки | 2 | 4 GB | 25 GB | `false` | `envs/stage/stage.tfvars` |
| `prod` | Production-like foundation | 4 | 8 GB | 50 GB | `false` | `envs/prod/prod.tfvars` |

В `.tfvars` оставлены заглушки `replace-with-cloud-id`, `replace-with-folder-id` и `replace-with-*-subnet-id`. Реальные cloud/folder/subnet IDs, приватные ключи, OAuth-токены, локальные `terraform.tfvars`, `.terraform/`, state и plan-файлы в репозиторий не включены.

## Входные параметры модуля

| Переменная | Тип | Назначение |
|---|---|---|
| `project_name` | `string` | Префикс проекта для имён и labels. |
| `environment` | `string` | Окружение: `dev`, `stage`, `prod`. |
| `folder_id` | `string` | Yandex Cloud folder ID для создаваемых ресурсов. |
| `zone` | `string` | Зона доступности. |
| `instance_name` | `string` | Имя VM. Если `null`, генерируется из проекта и окружения. |
| `platform_id` | `string` | Платформа VM. |
| `image_family` | `string` | Семейство публичного образа. |
| `cores` | `number` | Количество vCPU. |
| `memory` | `number` | RAM в GB. |
| `disk_size` | `number` | Размер подключаемого boot disk в GB. |
| `disk_type` | `string` | Тип подключаемого boot disk. |
| `subnet_id` | `string` | ID существующей subnet для сетевого интерфейса VM. |
| `nat` | `bool` | Создавать ли публичный NAT-адрес для VM. |
| `security_group_ids` | `list(string)` | Опциональные security groups для сетевого интерфейса. |
| `ssh_user` | `string` | Пользователь Linux для SSH-ключа. |
| `ssh_public_key` | `string` | Публичный SSH-ключ. Приватные ключи сюда не передаются. |
| `labels` | `map(string)` | Дополнительные labels, объединяются с базовыми. |

## Outputs

| Output | Значение |
|---|---|
| `instance_id` | ID созданной VM. |
| `instance_name` | Имя созданной VM. |
| `disk_id` | ID созданного подключаемого boot disk. |
| `disk_name` | Имя созданного подключаемого boot disk. |
| `subnet_id` | ID subnet, использованный сетевым интерфейсом. |
| `internal_ip_address` | Внутренний IPv4-адрес VM. |
| `external_ip_address` | Внешний IPv4-адрес VM, если включён NAT. |
| `environment` | Имя окружения. |
| `labels` | Итоговые labels, применённые к ресурсам. |

## Как проверить

```bash
terraform fmt -recursive Task1Advanced

terraform -chdir=Task1Advanced/modules/vm init -backend=false
terraform -chdir=Task1Advanced/modules/vm validate

terraform -chdir=Task1Advanced/envs/dev init -backend=false
terraform -chdir=Task1Advanced/envs/dev validate

terraform -chdir=Task1Advanced/envs/stage init -backend=false
terraform -chdir=Task1Advanced/envs/stage validate

terraform -chdir=Task1Advanced/envs/prod init -backend=false
terraform -chdir=Task1Advanced/envs/prod validate
```

## Как запустить окружения

После настройки Yandex Cloud credentials и замены заглушек в `.tfvars`:

```bash
terraform -chdir=Task1Advanced/envs/dev plan -var-file=dev.tfvars
terraform -chdir=Task1Advanced/envs/dev apply -var-file=dev.tfvars

terraform -chdir=Task1Advanced/envs/stage plan -var-file=stage.tfvars
terraform -chdir=Task1Advanced/envs/stage apply -var-file=stage.tfvars

terraform -chdir=Task1Advanced/envs/prod plan -var-file=prod.tfvars
terraform -chdir=Task1Advanced/envs/prod apply -var-file=prod.tfvars
```

`apply` создаёт платные облачные ресурсы, поэтому в рамках локальной проверки выполняется только `init -backend=false` и `validate`.
