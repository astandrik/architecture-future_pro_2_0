# Обоснование технологических решений

## Матрица решений

| Решение | Выбор | Обоснование | Отклонённые альтернативы | Риски | Влияние на TCO | Этап roadmap |
|---|---|---|---|---|---|---|
| Cloud platform | Yandex Cloud | Покрывает Object Storage, managed data services, IAM и audit для целевой data platform | Оставить всё on-premise, перейти в несвязанный cloud | R8, R9, R11 | Переводит затраты из CapEx в Opex и сохраняет elastic growth | `0-6`, затем все этапы |
| Lakehouse storage | Object Storage + Apache Iceberg | Слой рассчитан на сотни TB, раздельные storage/compute и schema evolution | DWH-only, raw Data Lake без table format | R4, R8, R12 | Storage масштабируется дешевле, чем в DWH-only; требуются вложения в governance | `0-6`, `6-18` |
| Catalog and governance | DataHub | Ведёт ownership, glossary, lineage и access workflow для Data Mesh | Wiki/Excel catalog, ownership у центральной DWH-команды | R1, R2, R4, R7 | Добавляет стоимость платформы, но снижает compliance/discovery cost | `0-6` |
| Self-service SQL | Dremio over governed marts | Аналитикам нужен SQL-доступ к Lakehouse без публикации excluded medical datasets: `медицинские карты`, `истории болезней`, `результаты медицинских исследований` | Direct Power BI over DWH, ad hoc SQL over raw buckets | R2, R4, R8 | Compute cost нужно контролировать через governance, зато снижается latency отчётов | `0-6`, `6-18` |
| Event backbone | Kafka-compatible streaming | Служит для weak coupling, near-real-time processing и domain events | Apache Camel as target ESB, direct database integrations | R5, R6, R12 | Добавляет streaming run-rate, но снижает стоимость интеграционного coupling | `0-6`, `6-18` |
| Event contracts | Schema Registry + DLQ | Ограничивает schema drift и защищает consumers от invalid messages | Unversioned JSON over queues, synchronous point-to-point calls | R4, R5, R12 | Небольшая platform cost, заметное снижение incident risk | `0-6` |
| Migration approach | CDC + anti-corruption layer | DWH/Camel мигрируются поэтапно, без big-bang cutover | Сначала переписать всё, оставить direct legacy integrations | R5, R6 | Создаёт dual-run cost, но снижает outage risk | `0-6`, `6-18` |
| Infrastructure delivery | Terraform + GitLab CI | Plans проходят review, окружения воспроизводимы, state хранится отдельно | Manual console changes, scripts without state | R8, R10, R11 | Снижает стоимость ручных ошибок, требует pipeline governance | `0-6` |
| Legacy DWH strategy | Hold and migrate | SQL Server 2008 работает, но блокирует domain autonomy и несёт legacy risk | Продолжать добавлять DWH logic, big-bang replacement | R3, R5, R6 | Сначала возникает dual-run cost, затем снижается зависимость critical path | все этапы |
| PowerBuilder strategy | Eliminate from active development | Редкие навыки и DWH coupling замедляют изменения в клиниках | Бессрочно расширять текущий UI | R6, R10 | Стоимость замены сейчас, ниже long-term support burden потом | `6-18`, `18-36` |
| Camel strategy | Hold behind ACL | Camel может быть legacy bridge, но не должен стать target integration hub | Reuse Camel as central ESB | R5, R6 | Временная adapter cost, без возврата к central coupling | `0-6`, `6-18` |
| Medical data boundary | Exclude regulated medical data from analytics | Regulated medical datasets (`медицинские карты`, `истории болезней`, `результаты медицинских исследований`) не являются self-service analytics data products | Публиковать regulated medical data только с RBAC | R1, R2, R3, R13 | Сужает аналитический scope, но убирает высокий compliance exposure | все этапы |

## Почему не DWH-only

SQL Server 2008 DWH перегружен бизнес-логикой, интеграциями и тяжёлыми трансформациями. DWH-only оставит медленные отчёты и привязку новых доменов к центральной legacy-структуре.

Что меняется:

- DWH остаётся migration source и historical reporting bridge.
- Новые data products публикуют домены.
- Общие KPI управляются через DataHub и glossary, а не через скрытые SQL-процедуры.
- CDC и reconciliation снижают cutover risk.

## Почему не Camel как target integration backbone

Apache Camel подходит как compatibility adapter, но не как target event platform: он сохранит central hub. Вместо него используются domain event contracts, schema compatibility, DLQ ownership и streams.

Что меняется:

- Camel messages переводятся через anti-corruption layers.
- Новые интеграции используют зарегистрированные events и contracts.
- Invalid messages уходят в DLQ с owner и replay policy.
- Decommission dates ведутся в roadmap.

## Почему DataHub обязателен

Без DataHub или равнозначного каталога Data Mesh останется соглашением об именах. В DataHub ведутся owners, glossary terms, lineage, access requests и metadata для data products.

Контроль в DataHub:

- у каждого data product есть owner и SLA;
- у каждого sensitive dataset есть classification;
- у каждой cross-domain dependency есть lineage;
- access requests аудируемы;
- excluded medical datasets (`медицинские карты`, `истории болезней`, `результаты медицинских исследований`) не могут появиться в analytics catalog.

## Обоснование TCO

В первые 18 месяцев расходы растут из-за dual-run: DWH/Camel ещё работают, а Lakehouse, DataHub и event platform уже развёрнуты. Эта надбавка снижает риск cutover, даёт audit trail и позволяет запретить новые DWH-зависимости. Экономический эффект TCO складывается из:

- сокращения ручной сборки отчётов и reconciliation после переноса витрин в DataHub/Dremio;
- подключения fintech, clinics, AI, pharma и device domains через готовые event/data-product contracts;
- отказа от крупного DWH hardware refresh как основного способа масштабирования;
- FinOps-контроля через labels, budgets и lifecycle policies;
- снижения incident risk через contracts, DLQ, lineage и DR controls.

## Governance

- Technology radar review: раз в полгода для `Adopt`, ежеквартально для `Trial` и `Assess`, ежемесячно для `Hold`.
- ADR/RFC обязателен для новой platform, data или integration technology.
- CISO/DPO approval обязателен для medical, financial и personal data classifications.
- FinOps review обязателен перед масштабированием любой `Trial` technology.
