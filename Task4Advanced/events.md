# Каталог доменных событий

События описывают бизнес-факты после их наступления. Команды и внутренние поля агрегатов не публикуются напрямую; каждый event contract проходит schema compatibility, sensitivity classification и ownership review.

| Event | Context-source | Семантика | Минимальный контракт | Подписчики | Sensitivity |
|---|---|---|---|---|---|
| `AppointmentScheduled` | Clinic Operations / Patient Flow | Пациентский поток получил новую запись | `event_id`, `occurred_at`, `appointment_id`, `patient_flow_id`, `clinic_id`, `scheduled_at`, `service_type`, `schema_version` | Fintech / Banking, Data Platform / DataHub | Personal, no raw medical record |
| `VisitCompleted` | Clinic Operations / Patient Flow | Услуга оказана, визит завершён | `event_id`, `occurred_at`, `visit_id`, `appointment_id`, `patient_flow_id`, `clinic_id`, `service_code`, `completed_at`, `schema_version` | Fintech / Banking, AI Medical Services, Data Platform / DataHub | Personal, clinical metadata only |
| `InvoiceIssued` | Fintech / Banking | Сформирован счёт за услугу или договор | `event_id`, `occurred_at`, `invoice_id`, `payer_id`, `amount`, `currency`, `source_context`, `schema_version` | Clinic Operations / Patient Flow, Head Office | Financial |
| `PaymentReceived` | Fintech / Banking | Платёж подтверждён | `event_id`, `occurred_at`, `payment_id`, `invoice_id`, `amount`, `currency`, `payment_status`, `schema_version` | Clinic Operations / Patient Flow, Head Office | Financial |
| `CreditApproved` | Fintech / Banking | Кредитная заявка одобрена | `event_id`, `occurred_at`, `credit_application_id`, `customer_ref`, `decision`, `limit_band`, `schema_version` | Clinic Operations / Patient Flow, Head Office | Financial, regulated |
| `AIInferenceCompleted` | AI Medical Services | AI inference завершён, доступна service-quality metadata | `event_id`, `occurred_at`, `inference_run_id`, `model_version`, `workflow_id`, `quality_band`, `lineage_ref`, `schema_version` | Clinic Operations / Patient Flow, Data Platform / DataHub | Clinical metadata only |
| `InventoryAdjusted` | Head Office | Изменён инвентарный остаток | `event_id`, `occurred_at`, `inventory_item_id`, `location_id`, `quantity_delta`, `reason`, `schema_version` | Data Platform / DataHub, domain analytics | Corporate |
| `StaffingChanged` | Head Office | Изменились кадровые данные для корпоративных KPI | `event_id`, `occurred_at`, `staffing_record_id`, `department_id`, `change_type`, `schema_version` | Data Platform / DataHub | Personal, HR |
| `CorporateKpiApproved` | Head Office | Утверждено определение корпоративного KPI | `event_id`, `occurred_at`, `kpi_id`, `glossary_term_id`, `owner`, `formula_version`, `schema_version` | All domains, Data Platform / DataHub | Metadata |
| `PartnerDataReceived` | Pharma Partners | Получен партнёрский набор данных | `event_id`, `occurred_at`, `partner_batch_id`, `partner_id`, `contract_version`, `schema_version` | Data Platform / DataHub, partner analytics | Classified before use |
| `PartnerContractUpdated` | Pharma Partners | Обновлён партнёрский data contract | `event_id`, `occurred_at`, `partner_contract_id`, `partner_id`, `contract_version`, `effective_from`, `schema_version` | Data Platform / DataHub, Event platform | Metadata |
| `DeviceTelemetryReceived` | Medical Device / Electronics | Получена телеметрия медицинского оборудования | `event_id`, `occurred_at`, `device_id`, `stream_id`, `metric_type`, `metric_value_ref`, `schema_version` | Data Platform / DataHub, Device analytics | Classified before use |
| `DeviceMaintenanceRequired` | Medical Device / Electronics | Для устройства требуется сервисное действие | `event_id`, `occurred_at`, `maintenance_case_id`, `device_id`, `severity`, `reason`, `schema_version` | Head Office, Device operations | Operational |
| `SchemaRegistered` | Data Platform / DataHub | Зарегистрирована версия схемы | `event_id`, `occurred_at`, `schema_id`, `schema_version`, `compatibility_mode`, `owner`, `review_status` | All producing domains | Metadata |
| `DataProductPublished` | Data Platform / DataHub | Data product опубликован в каталоге | `event_id`, `occurred_at`, `data_product_id`, `owner`, `domain`, `sensitivity`, `sla`, `lineage_ref`, `schema_version` | Business users, analysts, partner domains | Sensitivity-tagged |
| `AccessApproved` | Data Platform / DataHub | Доступ к data product одобрен | `event_id`, `occurred_at`, `access_request_id`, `subject_id`, `data_product_id`, `policy_version`, `expires_at` | Dremio, Data Platform, requesting domains | Access-control metadata |
| `CdcEventCaptured` | Legacy DWH | Изменение из SQL Server 2008 DWH принято для миграции или сверки | `event_id`, `occurred_at`, `source_table`, `change_id`, `operation`, `classification`, `mapping_version` | Data Platform / DataHub, selected domains | Depends on source; classified before use |
| `LegacyMessageTranslated` | Legacy Camel ACL | Legacy message переведён в доменный контракт | `event_id`, `occurred_at`, `mapping_id`, `legacy_message_id`, `target_contract`, `mapping_version`, `decommission_date` | Selected target domains | Depends on source; classified before use |
| `MessageSentToDLQ` | Event platform | Сообщение отправлено в DLQ | `event_id`, `occurred_at`, `source_topic`, `message_id`, `reason`, `owner`, `replay_policy` | Producing domain, SRE, Data Platform / DataHub | Operational metadata |

## Запрещённые payloads

В self-service analytics и data product events не включаются медицинские карты, истории болезней и результаты медицинских исследований. Если такие данные обнаружены в событии или CDC payload, сообщение отправляется в DLQ, а pipeline блокируется до RCA и повторной classification.
