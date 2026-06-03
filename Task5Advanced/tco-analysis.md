# TCO-анализ

## Дата расчёта и источники

Дата расчёта: `2026-06-01`.

Это предварительная оценка, не коммерческое предложение. Перед закупкой конфигурации нужно пересчитать в актуальном калькуляторе провайдера.

Актуальность ссылок на официальные страницы тарифов повторно проверена `2026-06-02`.

Источники тарифов и правил тарификации:

| Источник | Для чего используется |
|---|---|
| [Yandex Cloud price calculator](https://yandex.cloud/en/prices) | Итоговая проверка конфигураций и run-rate |
| [Object Storage pricing](https://yandex.cloud/en/docs/storage/pricing) | Storage classes, operations, outgoing traffic |
| [Compute Cloud pricing](https://yandex.cloud/en/docs/compute/pricing) | Worker nodes, VM compute, disks, snapshots |
| [Managed Kubernetes pricing](https://yandex.cloud/en/docs/managed-kubernetes/pricing) | Kubernetes masters and outgoing traffic |
| [Managed Kafka pricing](https://yandex.cloud/en/docs/managed-kafka/pricing) | Broker hosts, ZooKeeper/KRaft hosts, storage, traffic |
| [Data Transfer pricing](https://yandex.cloud/en/docs/data-transfer/pricing) | Workers and delivered rows for migration/replication |
| [Managed PostgreSQL pricing](https://yandex.cloud/en/docs/managed-postgresql/pricing) | Metadata stores, host resources, storage and backups |

Валюта: RUB с НДС для российского договора. USD-примеры используются только как формула тарификации.

## Основные допущения

| Допущение | pilot | scale | target |
|---|---:|---:|---:|
| Горизонт | `0-6` месяцев | `6-18` месяцев | `18-36` месяцев |
| Домены | 2 | 4 | 6+ |
| Data volume в Lakehouse | 40-70 TB | 180-260 TB | 450-650 TB |
| Hot / standard storage | 70% | 55% | 40% |
| Cold/archive storage | 30% | 45% | 60% |
| Event traffic | 1-5 млн events/day | 10-40 млн events/day | 60-150 млн events/day |
| Data products | 2-4 | 10-18 | 25-40 |
| Активные пользователи аналитики в месяц | 50-100 | 250-500 | 800-1500 |
| Platform FTE | 5 | 10 | 8 |
| Loaded FTE cost | 450 000 RUB/месяц | 450 000 RUB/месяц | 450 000 RUB/месяц |

FTE включает зарплату, налоги, рабочее место, поддержку и накладные расходы. Для регионального запуска и banking compliance нужен отдельный security/compliance budget.

## Формула

Базовая формула месячного run-rate:

```text
monthly_run_rate =
  object_storage
  + compute_and_kubernetes
  + managed_kafka
  + metadata_stores
  + data_transfer
  + observability_security_backup
  + support
```

Формула migration investment:

```text
migration_investment =
  FTE_count * loaded_FTE_cost * duration
  + one_time_training
  + one_time_partner_support
  + dual_run_and_reconciliation
```

Формула TCO за 36 месяцев:

```text
TCO_36m =
  cloud_run_rate_by_stage
  + migration_investment
  + legacy_coexistence_cost
  + analyst_time_and_manual_reporting
  + training_and_governance_cost
```

## Покрытие обязательных статей затрат

| Статья из задания | Где учтена в расчёте |
|---|---|
| Инфраструктура | `Cloud run-rate`: Object Storage, compute/Kubernetes, Kafka-compatible streaming, Managed PostgreSQL, Data Transfer, monitoring, backup, KMS и support buffer. |
| Лицензии | `Legacy and coexistence cost`: SQL Server 2008 DWH, PowerBuilder, Apache Camel и Power BI over DWH как legacy license/support equivalent. |
| Сопровождение | `Migration and people cost`, `External expert review`, platform FTE, support buffer, SRE/DR и incident handling. |
| Время аналитиков | `Analyst time and manual report assembly`: ожидание DWH-отчётов, ручная сборка срезов и проверка кастомных Power BI reports. |

## Cloud run-rate

| Cost component | pilot RUB/месяц | scale RUB/месяц | target RUB/месяц | Комментарий |
|---|---:|---:|---:|---|
| Object Storage and operations | 120k-260k | 700k-1.4M | 1.5M-3.0M | Зависит от storage class mix, операций и lifecycle policies |
| Managed Kubernetes and compute nodes | 250k-520k | 900k-1.8M | 1.8M-3.4M | DataHub, Dremio, Airflow, platform services |
| Managed Kafka / streaming | 80k-180k | 500k-1.2M | 1.2M-2.8M | Brokers, coordination hosts, retention storage |
| Managed PostgreSQL metadata stores | 40k-90k | 120k-280k | 220k-500k | DataHub, Airflow, platform metadata |
| Data Transfer / CDC | 30k-120k | 180k-600k | 300k-1.0M | Высоко зависит от строк и количества workers |
| Monitoring, Audit Trails, backup, KMS, Lockbox | 80k-180k | 300k-700k | 600k-1.4M | Security and reliability baseline |
| Support and reserved capacity buffer | 50k-140k | 300k-800k | 700k-2.4M | Support tier, CVoS, buffer for peaks |
| **Итого** | **650k-1.49M** | **3.0M-6.78M** | **6.32M-14.5M** | Без учёта внутренних FTE |

## Migration and people cost

| Stage | Месяцы | Team assumption | Cost estimate |
|---|---:|---|---:|
| pilot | 6 | 5 FTE: platform, data, SRE, governance, migration | 13.5M RUB |
| scale | 12 | 10 FTE: platform team plus domain data engineers | 54.0M RUB |
| target | 18 | 8 FTE: steady-state platform and domain enablement | 64.8M RUB |
| Training and enablement | 36 | Data Mesh, DataHub, Kafka, Lakehouse, FinOps | 12M-18M RUB |
| External expert review | 36 | Security, banking compliance, lakehouse performance | 10M-20M RUB |

## Legacy and coexistence cost

| Component | Before transformation | During migration | Цель после 36 месяцев |
|---|---|---|---|
| SQL Server 2008 DWH | 4M-7M RUB/месяц equivalent: hardware, license, support, manual reports | Keep for CDC, reconciliation, historical reporting | Historical/archive only, no critical path |
| PowerBuilder | 0.8M-1.5M RUB/месяц equivalent: scarce support and slow changes | Keep for clinics until replacement screens are ready | Eliminate from active development |
| Apache Camel | 1M-2M RUB/месяц equivalent: legacy ESB support and incident handling | Keep behind anti-corruption layer | Eliminate from critical integrations |
| Power BI over DWH | 1.5M-2.5M RUB/месяц equivalent: custom reports and DWH transformations | Dual-run with governed marts | Tolerate only for historical reports or migrate |
| Analyst time and manual report assembly | 1.5M-4M RUB/месяц equivalent: ожидание DWH-отчётов, ручная сборка срезов, проверка кастомных Power BI reports | Снижается по мере появления self-service portal, governed marts и DataHub glossary | 0.3M-0.8M RUB/месяц |
| Manual reconciliation and incident cost | 2M-5M RUB/месяц | Drops as lineage and data quality gates mature | 0.5M-1M RUB/месяц |

## CapEx / Opex comparison

| Model | CapEx | Opex | Technical debt impact |
|---|---:|---:|---|
| Legacy-only scaling | 80M-140M RUB за 36 месяцев на hardware refresh, licenses and capacity | 8.5M-18M RUB/месяц and grows with regions | DWH remains bottleneck, report latency remains high |
| Cloud transformation | 0-20M RUB CapEx for migration tooling and one-time setup | 650k-14.5M RUB/месяц by stage plus FTE | Higher first-year investment, lower dependency on DWH/Camel |
| Target steady state | Minimal CapEx | 6.3M-14.5M RUB/месяц cloud plus 3.6M-5.4M RUB/месяц platform FTE | More predictable scaling, FinOps controls required |

## TCO за 36 месяцев

| Cost bucket | Estimate |
|---|---:|
| Cloud run-rate: пилот 6 месяцев | 3.9M-8.9M RUB |
| Cloud run-rate: scale 12 месяцев | 36.0M-81.4M RUB |
| Cloud run-rate: target 18 месяцев | 113.8M-261.0M RUB |
| Migration and platform FTE | 132.3M RUB |
| Training and enablement | 12M-18M RUB |
| External expert review | 10M-20M RUB |
| Legacy coexistence and analyst time during migration | 120M-210M RUB |
| **Total TCO за 36 месяцев** | **428M-732M RUB** |

Первые 18 месяцев - инвестиционная фаза с dual-run. Эффект: ниже Opex, быстрее отчётность, запуск fintech/medical/AI продуктов, подключение pharma/device, ниже регуляторный риск.

## FinOps guardrails

- Включить budget alerts по folder, environment, domain и data product.
- Ввести обязательные labels: `project`, `environment`, `domain`, `owner`, `cost_center`, `data_product`.
- Для Object Storage включить lifecycle policies: hot data в standard, старые raw/migration snapshots в cold/archive.
- Для Dremio и streaming workloads задать quotas, concurrency limits и autoscaling policy.
- Для `Trial` технологий задать exit criteria: latency, error rate, стоимость в месяц на data product, owner, support runbook.
- Ежемесячно сравнивать forecast vs actual и пересматривать roadmap при отклонении больше 15%.

## TCO risks

| Риск | Контроль |
|---|---|
| Cloud cost растёт быстрее ценности data products | FinOps owner, chargeback/showback, lifecycle policies, reserved capacity после stable baseline |
| Legacy bridge закрепляется как постоянная архитектура | Decommission backlog и ежемесячный TIME review |
| DataHub и Data Mesh не принимаются доменами | Domain Data Owners и platform enablement budget |
| Near-real-time workload масштабирован слишком рано | Расширять streaming только после pilot throughput evidence |
| Medical или financial compliance требует дополнительной изоляции | Держать compliance reserve в бюджете и исключить regulated medical datasets: `медицинские карты`, `истории болезней`, `результаты медицинских исследований` |
