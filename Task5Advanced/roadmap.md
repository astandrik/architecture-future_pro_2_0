# Roadmap трансформации

## Бизнес-цели

Roadmap разбит на три проверяемых горизонта:

- `0-6` месяцев: согласовать архитектуру, закрепить домены, запустить пилотные события и первые data products;
- `6-18` месяцев: вывести self-service portal в production и перенести критичные отчёты в governed marts;
- `18-36` месяцев: убрать Camel/DWH с critical path, подключить pharma/device и подготовить региональное масштабирование.

Медицинские карты, истории болезней и результаты медицинских исследований не входят в self-service analytics roadmap.

## Ключевые роли Data Mesh

| Роль | Зона ответственности | Этап roadmap |
|---|---|---|
| Data Product Owner | Бизнес-владелец data product, SLA, glossary terms, приоритизация метрик и доступов | `0-6`: первые `PatientFlowMart` и `FinancialCalculationsMart`; `6-18`: 10+ data products; `18-36`: partner/device products |
| Data Engineer | Контракты данных, ingestion, quality gates, Iceberg tables, lineage и автоматизация публикации | `0-6`: CDC и первые marts; `6-18`: streaming marts и ACL; `18-36`: масштабирование регионов и партнёров |
| BI-аналитик | Self-service отчёты, проверка витрин с бизнесом, миграция Power BI reports from DWH to governed marts | `0-6`: пилотные отчёты; `6-18`: production self-service portal; `18-36`: исторические отчёты без critical DWH path |
| Data Platform Lead | Общая платформа, DataHub, Dremio, FinOps, SRE controls и enablement доменов | Все этапы |
| CISO/DPO | Классификация medical/financial/personal data, access approvals и audit | Все этапы, особенно перед публикацией data products |

## TIME-инвентаризация

| System / capability | TIME | Причина | Roadmap action |
|---|---|---|---|
| Data Platform / DataHub | Invest | Высокая техническая и функциональная пригодность для Data Mesh | Развивать как control plane для owners, glossary, lineage, access |
| Domain data products | Invest | Нужны бизнесу для автономии доменов и KPI | Финансировать владельцев и data engineers в доменах |
| Object Storage + Iceberg Lakehouse | Invest | Масштабируемая база для BI/AI и сотен TB | Расширять storage tiering, quality gates, performance tuning |
| Event platform | Invest | Целевая слабосвязанная интеграция | Масштабировать после pilot throughput tests |
| Terraform / GitLab CI | Invest | Снижает ошибки ручной настройки | Распространить на platform and data infrastructure |
| SQL Server 2008 DWH | Migrate | Функционально важен, но технически устарел | CDC, strangler migration, запрет новой бизнес-логики |
| Power BI custom reports over DWH | Migrate | Бизнесу нужны отчёты, но источник нецелевой | Перенести в governed marts и self-service portal |
| Apache Camel ESB | Migrate | Интеграции важны, но архитектурно централизуют ландшафт | Anti-corruption layer, event contracts, decommission plan |
| PowerBuilder clinic UI | Eliminate | Низкая техническая пригодность и сложный найм | Заменить клиническими domain apps по мере вывода DWH logic |
| Direct DWH integrations | Eliminate | Воспроизводят bottleneck и coupling | Запретить для новых проектов, заменить events/contracts |
| Legacy historical reports | Tolerate | Нужны временно, низкая срочность после миграции | Оставить read-only до архивирования |

## Приоритизация

Шкала 1-10. WSJF = `(business value + time criticality + risk reduction + opportunity enablement) / effort`.

| Initiative | Business value | Time criticality | Risk reduction | Opportunity enablement | Effort | WSJF | Priority |
|---|---:|---:|---:|---:|---:|---:|---|
| Event standards, Schema Registry, DLQ | 8 | 9 | 9 | 8 | 4 | 8.5 | P1 |
| DataHub MVP and governed access workflow | 9 | 8 | 10 | 8 | 5 | 7.0 | P1 |
| PatientFlowMart and FinancialCalculationsMart | 10 | 8 | 7 | 9 | 6 | 5.7 | P1 |
| CDC from DWH and reconciliation | 8 | 8 | 9 | 7 | 7 | 4.6 | P1 |
| Dremio self-service portal pilot | 9 | 7 | 6 | 8 | 7 | 4.3 | P2 |
| PowerBuilder replacement planning | 7 | 5 | 8 | 6 | 8 | 3.3 | P2 |
| Pharma/device onboarding templates | 8 | 4 | 5 | 9 | 6 | 4.3 | P2 |

## `0-6` месяцев

| Initiative | Business goal | Technologies | Risks addressed | Cost band | Owner | Success metrics |
|---|---|---|---|---|---|---|
| Event foundation pilot | Единые принципы событий, queues, DLQ and schema catalog | Kafka-compatible streaming, Schema Registry, DLQ | R5, R6, R12 | 4M-8M RUB | Event Platform Lead | 4 registered event contracts, DLQ runbook, consumer lag SLO |
| DataHub MVP | Каталог data products, owners, glossary, access workflow | DataHub, Managed PostgreSQL, RBAC | R1, R2, R4, R7 | 5M-9M RUB | Data Governance Lead | 2 domains onboarded, 100% data products with owner and sensitivity |
| First marts | Пилот витрины для financial calculations и patient flow | Object Storage, Iceberg, Dremio, Airflow | R4, R8 | 8M-14M RUB | Data Platform Lead | `PatientFlowMart` and `FinancialCalculationsMart` published |
| DWH CDC pilot | Непрерывная миграция без big-bang | CDC, Data Transfer, ACL | R5, R6 | 4M-10M RUB | Migration Lead | CDC feed reconciled, no direct new DWH integration |
| FinOps baseline | Контроль cloud cost с первого этапа | labels, budgets, dashboards | R8, R9 | 1M-2M RUB | FinOps | 95% resources tagged, отклонение ежемесячного прогноза ниже 15% |

Результат `0-6`: два домена в пилоте, первые event contracts зарегистрированы, `PatientFlowMart` и `FinancialCalculationsMart` опубликованы в DataHub, excluded medical datasets не попали в analytics.

## `6-18` месяцев

| Initiative | Business goal | Technologies | Risks addressed | Cost band | Owner | Success metrics |
|---|---|---|---|---|---|---|
| Streaming marts expansion | Бизнес-пользователи работают с данными по новой архитектуре | Kafka-compatible streaming, Iceberg, Dremio | R4, R12 | 30M-55M RUB | Data Platform Lead | 10+ data products, report latency reduced from hours to minutes |
| Critical domain onboarding | Подключить AI, Head Office и выбранные fintech flows | DataHub, Data Mesh, domain contracts | R7, R13 | 25M-45M RUB | Enterprise Architect | Domain Data Owners назначены, glossary coverage выше 80% |
| ACL for DWH/Camel | Убрать прямую зависимость новых проектов от legacy | anti-corruption layer, CDC, DLQ | R5, R6 | 20M-40M RUB | Migration Lead | 70% new integrations use events/contracts |
| Self-service portal hardening | Сделать портал рабочим для доменных пользователей | Dremio, RBAC, audit, data quality gates | R1, R2, R11 | 18M-35M RUB | Self-Service Analytics Lead | Access approvals audited, data quality failures visible |
| SRE and DR baseline | Повысить надёжность аналитической платформы | monitoring, backups, DR drills | R11, R12 | 10M-25M RUB | SRE Lead | RPO/RTO определены, quarterly DR drill completed |

Результат `6-18`: production self-service portal, governed access, 10+ data products, критичные домены подключены, новые flows идут через events/contracts вместо direct DWH/Camel coupling.

## `18-36` месяцев

| Initiative | Business goal | Technologies | Risks addressed | Cost band | Owner | Success metrics |
|---|---|---|---|---|---|---|
| Remove critical DWH/Camel path | Целевая weakly-coupled event platform | events, CDC retirement, governed marts | R5, R6 | 35M-70M RUB | Migration Lead | Нет критичных synchronous DWH/Camel integrations |
| Pharma and device onboarding | Масштабировать новые направления бизнеса | event contracts, partner data products | R7, R12 | 25M-55M RUB | Partner Integration Owner | Partner и device data products опубликованы |
| Regional scale and compliance | Выход на 2-3 региона с локальными требованиями | Yandex Cloud landing zones, IAM, audit | R1, R8, R9 | 40M-90M RUB | Enterprise Architect | Regional controls approved, cost forecast per region |
| AI governance and lineage | Монетизация AI-функций без compliance gaps | DataHub lineage, model registry process | R13 | 18M-40M RUB | AI Domain Owner | Model/data lineage for all AI analytical products |
| Technology radar governance | Управляемый стек и регулярный review | radar as code, ADR/RFC, architecture board | R8, R9, R10 | 5M-12M RUB | Architecture Board | Semiannual radar review, decommission backlog tracked |

Результат `18-36`: DWH и Camel вне critical path, pharma/device подключены через стандартные contracts, региональные controls согласованы, radar и ADR/RFC управляют изменениями стека.

## Roadmap controls

- У каждой инициативы должны быть owner, cost band, success metric и risk link.
- Для каждой `Trial` technology нужны exit criteria перед переходом в `Adopt`.
- У каждой `Hold` technology должны быть decommission owner и target date.
- Roadmap пересматривается ежеквартально по scope, cost, compliance и изменениям бизнес-приоритетов.
