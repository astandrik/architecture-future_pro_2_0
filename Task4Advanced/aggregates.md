# Агрегаты и границы

Файл фиксирует основные агрегаты для bounded contexts из доменной модели. Агрегаты описаны на уровне, достаточном для Event Storming и проектирования контрактов; это не модель базы данных.

## Clinic Operations / Patient Flow

| Aggregate | Ключ | Инварианты | Основные события |
|---|---|---|---|
| Appointment | `appointment_id` | Запись принадлежит одному пациентскому потоку и имеет статус `scheduled`, `cancelled` или `completed`; повторная запись на тот же слот требует отдельной бизнес-проверки | `AppointmentScheduled` |
| Visit | `visit_id` | Визит может быть завершён только после фактического оказания услуги; в событие не включаются медицинские карты, истории болезней и результаты медицинских исследований | `VisitCompleted` |

## Protected Medical Records

| Aggregate | Ключ | Инварианты | Основные события |
|---|---|---|---|
| MedicalRecord | `medical_record_id` | Медицинские карты, истории болезней и результаты медицинских исследований остаются в regulated operational boundary; агрегат не публикуется как self-service analytics data product | Restricted clinical audit events only |
| MedicalDataAccessGrant | `access_grant_id` | Доступ выдаётся только через approval workflow с CISO/DPO policy и audit trail | Approved protected medical workflow signals |

## Fintech / Banking

| Aggregate | Ключ | Инварианты | Основные события |
|---|---|---|---|
| Invoice | `invoice_id` | Счёт связан с оказанной услугой или договором; повторная оплата не должна менять сумму без корректирующего события | `InvoiceIssued`, `PaymentReceived` |
| CreditApplication | `credit_application_id` | Решение по кредиту принимает banking domain owner; событие не раскрывает лишние персональные данные за пределами согласованного контракта | `CreditApproved` |

## AI Medical Services

| Aggregate | Ключ | Инварианты | Основные события |
|---|---|---|---|
| AIInferenceRun | `inference_run_id` | Результат inference публикуется как metadata/service quality event; training dataset, lineage и approval должны быть связаны с run | `AIInferenceCompleted` |
| ModelEvaluation | `model_version`, `evaluation_id` | Метрики качества модели версионируются; спорные результаты не становятся data product без review | `AIInferenceCompleted` |

## Head Office

| Aggregate | Ключ | Инварианты | Основные события |
|---|---|---|---|
| InventoryItem | `inventory_item_id` | Инвентарная позиция имеет owner и cost center; изменения должны попадать в corporate KPI lineage | `InventoryAdjusted` |
| StaffingRecord | `staffing_record_id` | Персональные данные сотрудников классифицируются до публикации агрегатов | `StaffingChanged` |
| CorporateKpiDefinition | `kpi_id` | KPI имеет владельца, glossary term и единую формулу для доменов | `CorporateKpiApproved` |

## Future Partner Contexts

| Aggregate | Ключ | Инварианты | Основные события |
|---|---|---|---|
| PartnerContract | `partner_contract_id` | Партнёрский контракт имеет owner, sensitivity classification и версию data contract | `PartnerContractUpdated` |
| PartnerDataBatch | `partner_batch_id` | Партнёрские данные проходят schema compatibility и quality gate до публикации | `PartnerDataReceived` |
| DeviceTelemetryStream | `device_id`, `stream_id` | Телеметрия устройства публикуется через стандартный event contract; clinical linkage разрешён только после classification | `DeviceTelemetryReceived` |
| DeviceMaintenanceCase | `maintenance_case_id` | Сервисное событие связано с устройством и не должно раскрывать protected medical records | `DeviceMaintenanceRequired` |

## Data Platform / DataHub

| Aggregate | Ключ | Инварианты | Основные события |
|---|---|---|---|
| SchemaContract | `schema_id`, `version` | Новая версия проходит compatibility check; breaking change требует отдельного approval | `SchemaRegistered`, `MessageSentToDLQ` |
| DataProduct | `data_product_id` | Перед публикацией обязательны owner, glossary terms, sensitivity tags, lineage, quality gate, SLA и access policy | `DataProductPublished` |
| AccessRequest | `access_request_id` | Доступ выдаётся по workflow и audit trail; denied request не должен обходиться прямым DWH/Camel доступом | `AccessApproved` |

## Legacy Migration

| Aggregate | Ключ | Инварианты | Основные события |
|---|---|---|---|
| LegacyDwhChange | `source_table`, `change_id` | CDC используется только для migration reconciliation; чувствительные данные классифицируются до использования | `CdcEventCaptured` |
| LegacyMessageMapping | `mapping_id` | Mapping имеет owner, lineage, DLQ policy и decommission date | `LegacyMessageTranslated`, `MessageSentToDLQ` |
