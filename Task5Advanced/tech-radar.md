# Расширенный технический радар

## Метод

Машинно-проверяемый источник радара — [tech-radar.yml](tech-radar.yml). Квадранты: `Platforms`, `Data & Analytics`, `Integration & Delivery`, `Methods & Governance`.

Кольца:

| Ring | Значение для "Будущее 2.0" |
|---|---|
| Adopt | Использовать как стандарт целевой архитектуры |
| Trial | Запускать в production-пилотах с метриками и ADR/RFC |
| Assess | Изучать как инвестицию, не ставить на критический путь без проверки |
| Hold | Не использовать в новых проектах, держать только для миграции или вывода |

## Adopt

| Technology | Quadrant | Owner | Movement | Review | Почему в кольце |
|---|---|---|---|---|---|
| Yandex Cloud | Platforms | Enterprise Architect | new | 6 месяцев | Базовая облачная платформа для инфраструктуры и data platform |
| Terraform | Integration & Delivery | Platform Lead | stable | 6 месяцев | IaC уже используется для воспроизводимой инфраструктуры |
| GitLab CI | Integration & Delivery | Platform Lead | stable | 6 месяцев | CI/CD контур для Terraform lifecycle |
| Yandex Object Storage | Platforms | Data Platform Lead | new | 6 месяцев | S3-compatible storage для state и Lakehouse |
| Apache Iceberg | Data & Analytics | Data Platform Lead | new | 6 месяцев | Табличный формат Lakehouse для BI/AI |
| DataHub | Methods & Governance | Data Governance Lead | new | 6 месяцев | Data Catalog, owners, glossary, lineage и access workflow |
| Schema Registry | Integration & Delivery | Event Platform Lead | new | 6 месяцев | Версионирование и совместимость доменных event contracts |
| DLQ | Integration & Delivery | SRE Lead | new | 6 месяцев | Обязательный reliability pattern для событий и legacy adapters |
| CDC | Integration & Delivery | Migration Lead | new | 6 месяцев | Переходный механизм от SQL Server 2008 DWH |
| Managed PostgreSQL | Platforms | Platform Lead | new | 6 месяцев | Управляемое хранилище метаданных платформы |
| Python | Data & Analytics | AI Domain Owner | stable | 6 месяцев | Базовый стек текущих AI medical services |
| Go | Integration & Delivery | Fintech Domain Owner | stable | 6 месяцев | Подходит текущим fintech-сервисам с высокой нагрузкой |
| Java | Integration & Delivery | Fintech Domain Owner | stable | 6 месяцев | Стабильный стек fintech-сервисов |
| Data Mesh | Methods & Governance | Enterprise Architect | new | 6 месяцев | Целевая модель владения data products |
| Event-Driven Architecture | Methods & Governance | Enterprise Architect | new | 6 месяцев | Целевая модель слабосвязанных доменов, событий и реактивных потоков |
| ADR/RFC for technology changes | Methods & Governance | Architecture Board | new | 6 месяцев | Контроль движения технологий по радару |

## Trial

| Technology | Quadrant | Owner | Movement | Review | Условие расширения |
|---|---|---|---|---|---|
| Nessie | Data & Analytics | Data Platform Lead | new | 3 месяца | Доказать стабильность catalog/versioning на пилотных data products |
| Dremio | Data & Analytics | Self-Service Analytics Lead | new | 3 месяца | Подтвердить latency, concurrency и cost guardrails |
| Apache Airflow | Integration & Delivery | Data Platform Lead | new | 3 месяца | Проверить orchestration без централизации всех доменных поставок |
| Kafka-compatible streaming | Integration & Delivery | Event Platform Lead | new | 3 месяца | Подтвердить throughput, consumer lag, schema policy и DLQ process |
| Yandex Data Transfer | Platforms | Migration Lead | new | 3 месяца | Проверить connector coverage для реальных legacy sources |
| Managed Kubernetes | Platforms | SRE Lead | new | 3 месяца | Доказать управляемость cost, security и platform operations |
| Power BI over governed marts | Data & Analytics | Self-Service Analytics Lead | changed | 3 месяца | Разрешить как BI UI только поверх governed marts, не raw DWH |
| Self-service BI | Data & Analytics | Self-Service Analytics Lead | changed | 3 месяца | Подтвердить governed report building через DataHub/Dremio marts, без direct DWH customizations |

## Assess

| Technology | Quadrant | Owner | Movement | Review | Что проверяем |
|---|---|---|---|---|---|
| OpenLineage | Methods & Governance | Data Governance Lead | new | 6 месяцев | Нужен ли общий стандарт lineage поверх DataHub-native ingestion |
| MLflow Model Registry | Data & Analytics | AI Domain Owner | new | 6 месяцев | Нужен ли отдельный model registry для AI medical services перед монетизацией |

## Hold

| Technology | Quadrant | Owner | Movement | Review | Ограничение |
|---|---|---|---|---|---|
| SQL Server 2008 DWH | Data & Analytics | Migration Lead | down | ежемесячно | Только historical source и CDC bridge, без новой бизнес-логики |
| PowerBuilder | Integration & Delivery | Clinics Domain Owner | down | ежемесячно | Только поддержка legacy UI до замены клиническими domain apps |
| Apache Camel as legacy ESB | Integration & Delivery | Migration Lead | down | ежемесячно | Только behind anti-corruption layer, не target event backbone |
| Power BI over DWH | Data & Analytics | Self-Service Analytics Lead | down | ежемесячно | Запрет новых кастомизаций поверх DWH, миграция в governed marts |

## Управление радаром

- Review cadence: `Hold` - ежемесячно на migration review, `Trial` - раз в квартал, `Adopt` - раз в полгода.
- Для движения `Trial -> Adopt` нужен ADR/RFC с нагрузочным результатом, cost estimate, владельцем и rollback plan.
- Для `Hold` нужен decommission backlog: владелец, зависимые отчёты или процессы, целевой replacement и дата вывода.
- Медицинские карты, истории болезней и результаты медицинских исследований не могут быть добавлены в radar как self-service analytics data product.
