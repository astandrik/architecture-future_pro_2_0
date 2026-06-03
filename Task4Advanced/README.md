# Моделирование домена и интеграций

## Артефакты

- [bounded-contexts.drawio](bounded-contexts.drawio), [bounded-contexts.png](bounded-contexts.png) — схема `Будущее 2.0 - bounded context map`.
- [event-storming.drawio](event-storming.drawio), [event-storming.png](event-storming.png) — схема `Будущее 2.0 - high-level Event Storming`.
- [integrations.md](integrations.md) — аргументация доменов, событий, контрактов и переходных интеграций.
- [aggregates.md](aggregates.md) — агрегаты, границы, инварианты и ключи.
- [events.md](events.md) — каталог доменных событий с источниками, подписчиками и минимальными контрактами.
- [justification.md](justification.md) — обоснование событийного подхода по сравнению с Camel/DWH.

## Опорная модель

Интеграционная граница модели: бизнес-домены публикуют domain events и data products; Data Platform ведёт схемы, каталог, доступы и lineage; DWH/Camel дают только CDC и translated legacy messages на период миграции.

## Bounded contexts

| Bounded context | Владелец | Основная ответственность | Данные / data products |
|---|---|---|---|
| Clinic Operations / Patient Flow | Clinics Domain Owner | Запись, визит, оказание услуги, операционный пациентский поток | `PatientFlowMart`, обезличенные агрегаты по потоку пациентов |
| Protected Medical Records | Medical Data Owner, CISO/DPO | Медицинские карты, истории болезней, результаты медицинских исследований в регулируемом operational boundary | Не публикует эти данные в self-service analytics |
| AI Medical Services | AI Domain Owner | AI inference, качество AI-сервисов, связь с разрешёнными клиническими процессами | `AIServiceKpiMart`, метрики AI-сервисов без раскрытия запрещённых медицинских данных |
| Fintech / Banking | Fintech Domain Owner | Счета, платежи, кредиты, банковские ограничения и финансовая история | `FinancialCalculationsMart`, `CreditRiskMart` |
| Head Office | Corporate Data Owner | Персонал, инвентаризация, финансовая отчётность, корпоративные KPI | `InventoryKpiMart`, corporate KPI products |
| Pharma Partners | Partner Integration Owner | Будущие pharma-партнёры и партнёрские data contracts | `PharmaPartnerMart` |
| Medical Device / Electronics | Device Domain Owner | Телеметрия оборудования, жизненный цикл устройств и сервисные события | `DeviceTelemetryMart` |
| Data Platform / DataHub | Data Platform Lead | DataHub, business glossary, owners, lineage, access workflow, schema registry | Каталог data products, lineage, владельцы, политики доступа |
| Legacy DWH | Migration Lead | SQL Server 2008 DWH как источник исторических данных и CDC на переходном этапе | CDC feed, legacy BI compatibility |
| Legacy Camel | Migration Lead | Apache Camel как старая шина и источник legacy messages | Messages через anti-corruption layer |

Группы и платформенные области на схеме:

| Label на схеме | Состав |
|---|---|
| `Core business bounded contexts` | Clinic Operations / Patient Flow, Fintech / Banking, AI Medical Services, Head Office. |
| `Regulated operational boundary` | `Protected Medical Records` и запрет публикации медицинских данных в self-service analytics. |
| `Future partner bounded contexts` | Pharma Partners, Medical Device / Electronics. |
| `Data platform and governance` | `Event platform`, `Data Platform / DataHub`, `Data Lakehouse`, `Governed access`, `Data products marketplace`. |
| `Legacy migration bounded contexts` | `Legacy DWH`, `Legacy Camel`, `Anti-corruption layer`. |

## Event Storming summary

Event Storming фиксирует цепочку `Clinic -> finance -> AI -> data products -> analytics`: команды остаются внутри домена, наружу уходят только завершившиеся business facts.

Легенда схемы: `Command`, `Domain event`, `Policy / rule`, `Read model / data product`.

Ключевые команды:

- `Schedule Appointment`
- `Complete Visit`
- `Issue Invoice`
- `Request Credit`
- `Run AI Inference`
- `Register Schema`
- `Capture Legacy Change`
- `Publish Data Product`
- `Request Access`

Ключевые события:

- `AppointmentScheduled`
- `VisitCompleted`
- `InvoiceIssued`
- `PaymentReceived`
- `CreditApproved`
- `AIInferenceCompleted`
- `SchemaRegistered`
- `CdcEventCaptured`
- `LegacyMessageTranslated`
- `DataProductPublished`
- `AccessApproved`
- `MessageSentToDLQ`

Read models / data products на схеме:

- `PatientFlowMart`
- `FinancialCalculationsMart`
- `CreditRiskMart`
- `AIServiceKpiMart`
- `InventoryKpiMart`
- `Planned PharmaPartnerMart`
- `Planned DeviceTelemetryMart`

Политики и ограничения:

- `Policy schema compatibility check` перед публикацией событий;
- sensitivity classification перед публикацией data product;
- `Policy access approval` через DataHub/Data Catalog;
- `Policy DLQ routing` для невалидных сообщений;
- `Policy data quality gate` перед публикацией витрин;
- медицинские карты, истории болезней и результаты медицинских исследований не публикуются в analytics.

Подробный каталог событий вынесен в [events.md](events.md), агрегаты и их инварианты — в [aggregates.md](aggregates.md).

## Ограничение по медицинским данным

Медицинские карты, истории болезней и результаты медицинских исследований не являются self-service analytics data products. Они остаются в `Protected Medical Records`.

В аналитическую платформу публикуются только агрегаты и обезличенные показатели. Каждый data product проходит sensitivity classification, owner review, quality gate и access workflow.

## Переходный период

| Этап | Доменная интеграция |
|---|---|
| `0-6` месяцев | Пилот для `Clinic Operations / Patient Flow` и `Fintech / Banking`: Schema Registry, DLQ, первые события, первые data products, CDC из DWH |
| `6-18` месяцев | Подключение критичных доменов, anti-corruption layers для DWH/Camel, потоковые витрины, DataHub lineage и access workflow |
| `18-36` месяцев | Отказ от синхронных интеграций через DWH/Camel на критическом пути; pharma/device подключаются через события и data product contracts |
