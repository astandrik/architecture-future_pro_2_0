# Целевая архитектура и риски внедрения

## Артефакты

- [c4-target-architecture.drawio](c4-target-architecture.drawio) — C4 Container + Component-level диаграмма целевой архитектуры.
- [risk-map.md](risk-map.md) — карта рисков внедрения с архитектурными, организационными и технологическими рисками.
- [risk-management-plan.md](risk-management-plan.md) — план управления рисками с техническими и управленческими мерами.

C4 выполнена на уровне Container. Внутри контейнеров показаны component-level детали: акторы, legacy-компоненты, домены, event platform, Schema Registry, DLQ, ingestion, Data Lakehouse, DataHub и self-service portal. Низкоуровневые детали реализации в диаграмму не включены.

## Исходный ландшафт

Текущий контур построен вокруг DWH на Microsoft SQL Server 2008. В нём лежат клиентские и финансовые данные, персонал, инвентаризация, отчётность и регулируемые медицинские данные.

UI — PowerBuilder, BI — Power BI, интеграции — Apache Camel.

По исходной схеме потоков данных текущие связи выглядят так:

| Источник | Приёмник | Тип данных | Вывод для целевой архитектуры |
|---|---|---|---|
| Клиентский интерфейс оператора | DWH | Медицинские данные, снимки | DWH участвует в операционном медицинском потоке и должен мигрироваться осторожно через shadow-run/CDC. |
| DWH | BI-система | Данные для отчётности | BI зависит от DWH напрямую; целевое состояние должно перевести отчётность на governed marts и self-service portal. |
| DWH | ESB | Данные legacy-контура | DWH используется как integration hub, а не только как аналитическое хранилище. |
| ИИ-сервисы | ESB | Медицинские данные | AI-поток должен быть отделён от self-service analytics и проходить через protected medical boundary. |
| Финтех-сервисы | ESB | Финансовые данные | Финансовый домен связан с legacy-шиной и требует отдельного regulated banking boundary. |
| ESB | Внутренние сервисы | Внутренние финансовые данные, управление клиниками | Операционные внутренние процессы зависят от Camel и должны выводиться через anti-corruption layer. |

Основные проблемы:

- DWH стал центром интеграций и бизнес-логики, поэтому новые направления требуют изменений в общем ядре.
- Формирование сложных отчётов занимает часы из-за объёма данных в сотни ТБ и большого количества трансформаций.
- PowerBuilder, SQL Server 2008 и Camel создают legacy-зависимость и ограничивают скорость изменений.
- Финтех, клиники, AI-сервисы и будущие pharma/device-направления имеют разные требования к данным, доступам и регуляторике.

## Целевая архитектура

Целевая модель — cloud data platform в Yandex Cloud. Операционные домены публикуют события и data products, платформенный слой отвечает за каталог, доступы, lineage и витрины, а DWH/Camel остаются только как источники CDC и legacy adapters.

Компоненты и подписи C4:

| C4 zone / container | Архитектурное назначение |
|---|---|
| `Legacy migration zone` | Переходный контур: `SQL Server 2008 DWH`, `PowerBuilder UI + Power BI over DWH`, `Apache Camel ESB`, `Anti-corruption layer`. |
| `Business domains - Data Mesh ownership` | `Core domains`: Head Office, Clinics / Patient Flow, Fintech / Banking, AI Medical Services; `Future partner domains`: Pharma Partners, Medical Device / Electronics. |
| `Excluded Medical Data Boundary` | Медицинские карты, истории болезней и результаты медицинских исследований исключены из self-service analytics. |
| `Event and ingestion platform` | `Kafka-compatible Event Streaming`, `Schema Registry + DLQ`, `CDC / Stream ingestion / ELT`. |
| `Yandex Cloud Data Lakehouse and self-service platform` | `Object Storage + Apache Iceberg`, `Approved Data Products`, `DataHub Data Catalog`, `Dremio Self-service SQL Portal`. |

Nessie catalog и Airflow/ELT относятся к реализации Data Lakehouse, но не вынесены отдельными элементами уровня C4 Container.

## Ограничение по медицинским данным

Медицинские карты, истории болезней и результаты медицинских исследований не публикуются в аналитику и остаются в regulated operational medical boundary.

В self-service portal попадают только разрешённые data products: агрегаты по пациентскому потоку, обезличенные метрики, финансы, инвентаризация, персонал, KPI и lineage.

## Как архитектура снижает зависимость от DWH

DWH больше не принимает новую бизнес-логику. Новые направления подключаются через domain events, data product contracts и streaming marts; DataHub фиксирует владельца, схему, lineage, SLA и правила доступа.

Через три года критичный путь не зависит от Camel/DWH. Legacy остаётся только для исторических отчётов, архива и адаптеров с owner, SLO и датой вывода.

## Этапы трансформации

| Этап | Цель | Основной результат |
|---|---|---|
| `0-6` месяцев | Пилот в 1-2 доменах: финансовые расчёты и пациентский поток | Event standards, Schema Registry, DLQ, первые CDC-потоки, первые data products в DataHub |
| `6-18` месяцев | Расширение на критические домены | Потоковые витрины, anti-corruption layers для Camel/DWH, RBAC, data quality gates, lineage |
| `18-36` месяцев | Переход к доменной аналитике на потоках | Отказ от синхронных интеграций на критическом пути, DWH/Camel только как compatibility bridges, масштабирование на pharma/device |
