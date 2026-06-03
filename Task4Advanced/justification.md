# Обоснование событийного подхода

## Почему не Camel/DWH как целевой центр интеграций

Текущий DWH на SQL Server 2008 и Apache Camel уже стали общим узким местом. Новые финтех-, AI-, pharma- и device-направления вынуждены добавлять бизнес-логику в общий legacy-контур, из-за чего растёт coupling, усложняется регуляторный контроль и отчёты остаются медленными.

Camel и DWH сохраняются только как migration bridges:

- DWH даёт historical source, CDC и reconciliation на переходном этапе.
- Camel messages переводятся через anti-corruption layer.
- Каждый legacy mapping получает owner, lineage, DLQ policy и decommission date.
- Новые direct DWH/Camel dependencies запрещаются architecture review.

## Почему domain events

Domain events фиксируют бизнес-факты после завершения операции в bounded context. Клиники, банк, AI-сервисы, pharma-партнёры и device-домен меняют свои модели независимо, но публикуют события по согласованным контрактам.

Что меняется:

- меньше изменений в DWH при подключении новых направлений;
- быстрее onboarding партнёров через versioned contracts;
- проще перейти от batch-отчётности к near-real-time витринам;
- легче изолировать regulated medical boundary;
- ниже риск скрытого coupling через Power BI custom reports over DWH.

Практический смысл: витрины и downstream-процессы обновляются по событиям; пакетные DWH-пересчёты остаются только для исторических отчётов и сверки миграции.

## Эффект для компании

| Свойство | За счёт чего достигается |
|---|---|
| Гибкость | Новый домен подключается через event contract и data product contract без изменения общей DWH-модели и без прямой зависимости от Camel. |
| Масштабируемость | Потоки событий, Schema Registry, DLQ и доменные data products масштабируются по доменам: fintech, clinics, AI, pharma и device могут развиваться независимо. |
| Скорость реакции | Near-real-time events обновляют витрины быстрее пакетных DWH-пересчётов; потребители получают business facts сразу после завершения операции в домене. |

## Контроль качества и безопасности

Событийный подход не означает свободную публикацию данных. Перед публикацией работают platform guardrails:

- Schema Registry проверяет совместимость event contracts.
- Sensitivity classification запрещает вывод медицинских карт, историй болезней и результатов медицинских исследований в analytics.
- DataHub хранит owners, glossary, lineage, access workflow и audit metadata.
- DLQ фиксирует невалидные сообщения и даёт управляемый replay.
- Data quality gate проверяет data products перед публикацией в self-service portal.

## Связь с этапами трансформации

| Этап | Что меняется |
|---|---|
| `0-6` месяцев | Пилотные события для Clinic Operations / Patient Flow и Fintech / Banking, Schema Registry, DLQ, первые CDC feeds и первые data products |
| `6-18` месяцев | Критичные домены подключаются к events/contracts; DWH/Camel закрываются anti-corruption layers; появляются streaming marts |
| `18-36` месяцев | Критичный путь не зависит от synchronous DWH/Camel integrations; pharma/device домены подключаются через стандартные contracts |

## Когда синхронные API допустимы

Синхронные API остаются для пользовательских команд, lookup-сценариев и workflow, где нужен немедленный ответ. Междоменные бизнес-факты, аналитические обновления, CDC, partner feeds и device telemetry идут через events, чтобы не возвращать DWH или Camel в роль центрального integration hub.
