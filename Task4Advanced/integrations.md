# Интеграции, события и контракты

## Принципы

- Междоменные связи строятся через asynchronous domain events и версионированные contracts.
- Аналитика строится через governed data products, зарегистрированные в DataHub/Data Catalog.
- DWH и Camel не используются для новых прямых интеграций; на переходном этапе они подключаются через CDC и anti-corruption layer.
- DataHub хранит owners, glossary, lineage, sensitivity tags, access workflow и документацию data products.
- Protected Medical Records не публикует медицинские карты, истории болезней и результаты медицинских исследований в self-service analytics.

## Текущие legacy-потоки из задания

Скриншот потоков данных показывает, какие связи нужно разорвать или обернуть переходными слоями:

| Current flow | Data | Target treatment |
|---|---|---|
| Клиентский интерфейс оператора -> DWH | Медицинские данные, снимки | Перевести в `Protected Medical Records` и `Clinic Operations`; DWH оставить historical/CDC source. |
| DWH -> BI-система | Данные для отчётов | Заменить на governed marts через DataHub/Dremio; Power BI over DWH оставить только временно. |
| DWH <-> ESB | Legacy operational data | Завести CDC и anti-corruption mappings с owner и decommission date. |
| ИИ-сервисы <-> ESB | Медицинские данные | Перевести в protected workflow signals; не публиковать raw medical data в self-service analytics. |
| Финтех-сервисы <-> ESB | Финансовые данные | Перевести в `Fintech / Banking` events и regulated financial data products. |
| ESB -> внутренние сервисы | Внутренние финансы, управление клиниками | Перевести на domain events/API contracts по приоритету критичных процессов. |

## Домены и владение данными

| Context | Owner | Owned data | Data products | Published events | Consumed events |
|---|---|---|---|---|---|
| Clinic Operations / Patient Flow | Clinics Domain Owner | appointments, visits, services, anonymized patient-flow aggregates | `PatientFlowMart` | `AppointmentScheduled`, `VisitCompleted` | `PaymentReceived`, `AIInferenceCompleted`, `AccessApproved` |
| Protected Medical Records | Medical Data Owner, CISO/DPO | медицинские карты, истории болезней, результаты медицинских исследований | No self-service analytics data product | restricted clinical audit events only | `VisitCompleted`, approved AI workflow commands |
| AI Medical Services | AI Domain Owner | AI inference metadata, model run status, service quality metrics | `AIServiceKpiMart` | `AIInferenceCompleted` | `VisitCompleted`, approved protected medical workflow signals |
| Fintech / Banking | Fintech Domain Owner | invoices, accounts, payments, credits, financial history | `FinancialCalculationsMart`, `CreditRiskMart` | `InvoiceIssued`, `PaymentReceived`, `CreditApproved` | `VisitCompleted`, `AppointmentScheduled` |
| Head Office | Corporate Data Owner | personnel, inventory, corporate financial reporting, KPI definitions | `InventoryKpiMart`, corporate KPI products | `InventoryAdjusted`, `StaffingChanged`, `CorporateKpiApproved` | `DataProductPublished`, finance and clinic aggregate events |
| Pharma Partners | Partner Integration Owner | partner references, commercial agreements, approved partner metrics | `PharmaPartnerMart` | `PartnerDataReceived`, `PartnerContractUpdated` | `DataProductPublished`, approved aggregate clinic metrics |
| Medical Device / Electronics | Device Domain Owner | device telemetry, equipment lifecycle, maintenance events | `DeviceTelemetryMart` | `DeviceTelemetryReceived`, `DeviceMaintenanceRequired` | `VisitCompleted`, approved device assignment events |
| Data Platform / DataHub | Data Platform Lead | catalog metadata, ownership, glossary, lineage, access decisions, schema metadata | catalog of data products | `SchemaRegistered`, `DataProductPublished`, `AccessApproved`, `MessageSentToDLQ` | all published metadata and contract changes |
| Legacy DWH | Migration Lead | historical SQL Server 2008 DWH data, legacy BI dependencies | CDC feed only during migration | `CdcEventCaptured` | domain events for reconciliation only |
| Legacy Camel | Migration Lead | legacy integration messages | translated messages only during migration | `LegacyMessageTranslated`, `MessageSentToDLQ` | selected legacy-compatible domain events |

## Event and data-product contracts

| Contract | Owner | Producer | Consumers | Sensitivity | Schema / version policy | Delivery | Target read model |
|---|---|---|---|---|---|---|---|
| `AppointmentScheduled` | Clinics Domain Owner | Clinic Operations / Patient Flow | Fintech / Banking, Data Platform / DataHub | Personal, no raw medical record | JSON/Avro schema, backward-compatible minor versions | At-least-once event stream | `PatientFlowMart` |
| `VisitCompleted` | Clinics Domain Owner | Clinic Operations / Patient Flow | Fintech / Banking, AI Medical Services, Data Platform / DataHub | Personal, clinical metadata only | Schema Registry approval required | At-least-once event stream | `PatientFlowMart`, `FinancialCalculationsMart` |
| `InvoiceIssued` | Fintech Domain Owner | Fintech / Banking | Clinic Operations / Patient Flow, Head Office | Financial | Backward-compatible schema, PII tags required | At-least-once event stream | `FinancialCalculationsMart` |
| `PaymentReceived` | Fintech Domain Owner | Fintech / Banking | Clinic Operations / Patient Flow, Head Office | Financial | Backward-compatible schema, audit required | At-least-once event stream | `FinancialCalculationsMart` |
| `CreditApproved` | Fintech Domain Owner | Fintech / Banking | Clinic Operations / Patient Flow, Head Office | Financial, regulated | Strict compatibility, approval by banking owner | At-least-once event stream | `CreditRiskMart` |
| `AIInferenceCompleted` | AI Domain Owner | AI Medical Services | Clinic Operations / Patient Flow, Data Platform / DataHub | Clinical metadata only; без медицинских карт, историй болезней и результатов медицинских исследований | Model and dataset lineage required | Event stream plus lineage metadata | `AIServiceKpiMart` |
| `SchemaRegistered` | Data Platform Lead | Data Platform / DataHub | All producing domains | Metadata | Semantic versioning, compatibility check | Metadata event | DataHub catalog |
| `CdcEventCaptured` | Migration Lead | Legacy DWH | Data Platform / DataHub, selected domains | Depends on source; classified before use | Legacy mapping versioned in ACL | CDC stream | migration reconciliation views |
| `LegacyMessageTranslated` | Migration Lead | Legacy Camel ACL | selected target domains | Depends on source; classified before use | Mapping contract with decommission date | Event stream | temporary compatibility views |
| `DataProductPublished` | Domain Data Owner | Data Platform / DataHub | Business users, analysts, partner domains | Sensitivity-tagged | Owner, glossary, SLA and lineage mandatory | Metadata event plus catalog entry | DataHub catalog |
| `AccessApproved` | CISO/DPO, Data Platform Lead | Data Platform / DataHub | Dremio, Data Platform, requesting domains | Access-control metadata | Approval policy versioned | Metadata event | governed access workflow |
| `MessageSentToDLQ` | Data Platform Lead | Event platform | Producing domain, SRE, Data Platform / DataHub | Operational metadata | DLQ reason and replay policy required | DLQ topic | incident and quality dashboard |

## Integration patterns

### Asynchronous domain events

Для междоменных бизнес-фактов: appointment, visit, invoice, payment, credit, AI inference и partner/device events. DWH не становится интеграционным центром повторно.

### Governed data products

Для self-service reporting. Перед публикацией в DataHub у data product должны быть owner, glossary terms, sensitivity tags, quality checks, lineage, access policy и SLA.

### CDC from DWH

Только для миграции и сверки. `CdcEventCaptured` передаёт изменения из SQL Server 2008 DWH в event/data platform.

### Anti-corruption layer for DWH/Camel

Переходный слой между legacy contracts и domain contracts. ACL переводит DWH/Camel messages, фиксирует sensitivity/lineage и отправляет ошибки в DLQ. У каждого mapping есть owner и decommission date.

### DataHub / Data Catalog

Control plane для owners, business glossary, schema metadata, lineage и access workflow. DataHub не заменяет DWH; он отвечает за discoverability и governance.

## Transformation stages

### `0-6` месяцев

- Пилотные домены: `Clinic Operations / Patient Flow` и `Fintech / Banking`.
- Зарегистрировать схемы для `AppointmentScheduled`, `VisitCompleted`, `InvoiceIssued`, `PaymentReceived`.
- Включить DLQ и CDC для первых DWH migration feeds.
- Опубликовать первые `PatientFlowMart` и `FinancialCalculationsMart` в DataHub.

### `6-18` месяцев

- Подключить `AI Medical Services`, `Head Office` и критичные legacy ACL mappings.
- Запустить streaming marts и обязательные data quality gates.
- Добавить lineage для DWH/Camel migration flows.
- Перевести новые интеграции на events/contracts вместо direct DWH/Camel coupling.

### `18-36` месяцев

- Убрать критичные synchronous DWH/Camel integrations.
- Подключить `Pharma Partners` и `Medical Device / Electronics` через стандартные event contracts.
- Оставить DWH/Camel только для historical reporting, archive access или временных compatibility adapters.
- Регулярно проверять data products и events через DataHub governance.
