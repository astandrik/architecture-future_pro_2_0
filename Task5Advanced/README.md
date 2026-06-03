# Технологический стек, TCO и roadmap

## Артефакты

- [tech-radar.yml](tech-radar.yml) - radar as code, машинно-проверяемый инвентарь технологий.
- [tech-radar.md](tech-radar.md) - расширенный технический радар.
- [tco-analysis.md](tco-analysis.md) - TCO-анализ, источники тарифов, формулы и допущения.
- [roadmap.md](roadmap.md) - roadmap на горизонтах `0-6`, `6-18`, `18-36` месяцев.
- [technology-decisions.md](technology-decisions.md) - обоснование выбранных технологических решений.

## Базовые решения

- Yandex Cloud как базовая облачная платформа;
- Data Lakehouse на Object Storage, Apache Iceberg, Nessie и Dremio;
- Data Mesh и DataHub/Data Catalog как модель владения, поиска, lineage и access workflow;
- Event-Driven Architecture, Kafka-compatible event platform, Schema Registry, DLQ, CDC и anti-corruption layers;
- DWH на SQL Server 2008, PowerBuilder, Power BI поверх DWH и Apache Camel остаются только как legacy migration bridges.

Новые pharma/device/региональные направления подключаются через event contracts и data products. DWH не получает новые процедуры и синхронные зависимости.

## Ограничение по медицинским данным

Медицинские карты, истории болезней и результаты медицинских исследований не входят в self-service analytics и остаются в regulated operational medical boundary.

## Выбранный стек

| Слой | Целевые технологии | Роль |
|---|---|---|
| Cloud platform | Yandex Cloud, Managed Kubernetes, Managed PostgreSQL, Object Storage | Базовая инфраструктура, platform services, metadata stores и S3-compatible storage |
| IaC / delivery | Terraform, GitLab CI | Воспроизводимое управление инфраструктурой и controlled apply |
| Lakehouse | Object Storage, Apache Iceberg, Nessie, Dremio, Airflow | Хранение, таблицы, каталог версий, self-service SQL и ELT |
| Events | Kafka-compatible streaming, Schema Registry, DLQ, CDC, Data Transfer | Междоменные события, миграция и near-real-time потоки |
| Governance | DataHub, Data Mesh, Event-Driven Architecture, Self-service BI, ADR/RFC, RBAC, audit, lineage | Владение data products, глоссарий, доступы и управляемость стека |
| Legacy bridge | SQL Server 2008 DWH, Apache Camel, PowerBuilder, Power BI over DWH | Временная совместимость до вывода с критического пути |

## Источники тарифов

TCO считает run-rate по публичным тарифам Yandex Cloud и фиксирует допущения по объёму данных, событиям, пользователям, FTE и dual-run legacy:

- [Yandex Cloud price calculator](https://yandex.cloud/en/prices)
- [Object Storage pricing](https://yandex.cloud/en/docs/storage/pricing)
- [Compute Cloud pricing](https://yandex.cloud/en/docs/compute/pricing)
- [Managed Kubernetes pricing](https://yandex.cloud/en/docs/managed-kubernetes/pricing)
- [Managed Kafka pricing](https://yandex.cloud/en/docs/managed-kafka/pricing)
- [Data Transfer pricing](https://yandex.cloud/en/docs/data-transfer/pricing)
- [Managed PostgreSQL pricing](https://yandex.cloud/en/docs/managed-postgresql/pricing)
