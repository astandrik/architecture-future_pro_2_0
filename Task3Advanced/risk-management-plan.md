# План управления рисками

План связывает риски из [risk-map.md](risk-map.md) с ответственными ролями, мерами контроля и этапами трансформации.

| ID | Owner | Тип мер | Mitigation | Contingency | Метрики контроля | Этап |
|---|---|---|---|---|---|---|
| R1 | CISO/DPO | Управленческие + технические | Утвердить классификацию данных, правила обработки medical/financial data, mandatory audit trail и approval workflow для доступа | Остановить публикацию спорного data product, отозвать доступы, провести регуляторный review | 100% data products имеют sensitivity tags; 100% privileged access через workflow | `0-6` |
| R2 | CISO/DPO, Data Platform Lead | Технические | Включить IAM/RBAC, row/column policies, маскирование, encryption at rest/in transit и регулярный access review | Отключить affected dataset в Dremio/DataHub, rotated credentials, incident response | 0 критичных findings в access review; время отзыва доступа меньше 4 часов | `0-6`, затем постоянно |
| R3 | Enterprise Architect, CISO/DPO, Domain Data Owners | Управленческие + технические | Закрепить excluded medical data boundary: медицинские карты, истории болезней и результаты медицинских исследований не входят в self-service analytics | Немедленно удалить нарушающий набор из каталога, заблокировать ingestion pipeline, провести RCA | 0 data products с медицинскими картами, историями болезней или результатами медицинских исследований; 100% clinical datasets проходят compliance gate | `0-6` |
| R4 | Domain Data Owners, Data Governance Lead | Управленческие + технические | Ввести business glossary в DataHub, владельцев метрик, data quality checks и contract review для витрин | Пометить метрику как deprecated/disputed, вернуть отчёт к trusted source до исправления | Доля data products с owner и SLA — 100%; число disputed KPI снижается каждый квартал | `0-6`, `6-18` |
| R5 | Migration Lead, SRE Lead | Технические | Провести inventory DWH/Camel интеграций, настроить CDC shadow-run, rollback plan и поэтапный cutover | Вернуть трафик на legacy path, восстановить данные из snapshot/backup, заморозить rollout | 100% critical flows имеют rollback; shadow-run расхождение меньше согласованного порога | `0-6`, `6-18` |
| R6 | Enterprise Architect, Migration Lead | Управленческие | Ввести правило: новые интеграции только через events/API contracts; DWH/Camel bridge получает owner и decommission date | Заблокировать новый direct DWH/Camel dependency на architecture review | Количество direct DWH/Camel dependencies снижается; все bridges имеют target retirement date | `6-18`, `18-36` |
| R7 | Enterprise Architect, Domain Leads | Управленческие | Назначить Domain Data Owners, определить RACI, бюджет и definition of done для data products | Вернуть проблемный домен в assisted onboarding с platform team на ограниченный срок | У каждого домена есть owner; lead time публикации data product снижается | `0-6`, `6-18` |
| R8 | FinOps, Data Platform Lead | Управленческие + технические | Настроить budget alerts, object lifecycle policies, storage tiers, tagging, showback/chargeback и capacity review | Остановить неиспользуемые pipelines, заморозить тяжёлые ad-hoc workloads, пересмотреть retention | Cloud spend variance меньше 10%; storage без owner меньше 5%; idle compute снижается | `0-6`, затем постоянно |
| R9 | Enterprise Architect, Data Platform Lead | Технические | Использовать S3-compatible storage, Apache Iceberg, открытые форматы Parquet/Avro, portable CI/CD и ADR для PaaS-выбора | Подготовить export/runbook и fallback deployment для критичных компонентов | 100% critical datasets в открытых форматах; есть ежегодный portability review | `6-18` |
| R10 | Data Platform Lead, HR / Engineering Managers | Управленческие | Запустить enablement plan: training, pairing, runbooks, internal guild, vendor support only as bootstrap | Ограничить rollout до обученных доменов, привлечь временную expert team | Bus factor по ключевым компонентам больше 2; MTTR инцидентов платформы снижается | `0-6`, `6-18` |
| R11 | SRE Lead, Data Platform Lead | Технические | Определить RPO/RTO, multi-AZ deployment, backups, DLQ processing, monitoring, alerting и DR drills | Переключить read-only режим портала, replay events from Kafka/DLQ, restore catalog metadata | DR drill не реже раза в квартал; RPO/RTO соблюдаются; DLQ age в пределах SLA | `6-18` |
| R12 | Data Platform Lead, SRE Lead | Технические | Провести capacity tests, определить latency SLO, настроить autoscaling, backpressure и partitioning strategy | Перевести часть витрин в batch fallback, ограничить ad-hoc запросы, увеличить capacity | Consumer lag и freshness в пределах SLO; p95 latency витрин соответствует target | `6-18`, `18-36` |
| R13 | AI Lead, CISO/DPO, Data Governance Lead | Управленческие + технические | Версионировать training datasets через Lakehouse/Nessie, фиксировать lineage в DataHub, ввести approval workflow для AI datasets | Остановить модель или pipeline, если lineage/approval неполные; провести model risk review | 100% AI datasets имеют lineage, owner, approval и версию; audit findings закрываются в SLA | `6-18`, `18-36` |

## Контрольные точки по этапам

### `0-6` месяцев

- Утверждены data classification, excluded medical data boundary и access workflow.
- Запущены pilot domains: финансовые расчёты и пациентский поток.
- Введены Schema Registry, DLQ, первые CDC-потоки и первые data products в DataHub.
- Для DWH/Camel составлен inventory критичных интеграций.

### `6-18` месяцев

- Критичные домены подключены к event platform и Lakehouse.
- Запущены потоковые витрины и anti-corruption layers для Camel/DWH.
- Включены data quality gates, lineage, cost controls, DR drills и capacity tests.
- Legacy bridges получили owners, SLO и target retirement dates.

### `18-36` месяцев

- Критичные синхронные интеграции через Camel/DWH выведены из целевого пути.
- Pharma и device/electronics домены подключаются через стандартные события и data product contracts.
- DWH и Camel остаются только для исторических сценариев или временной совместимости.
- Data Mesh governance работает как регулярный операционный процесс.
