# dbt project — Battery Passport schema

## Run from this directory

```bash
cd dbt
dbt deps          # install dependencies
dbt build         # run all models + tests
dbt docs generate # build documentation
dbt docs serve    # browse docs locally
```

## Model layout

```
models/
├── staging/          # 1:1 with sources, light cleaning + typing only
│   ├── stg_attributes.sql
│   ├── stg_battery_types.sql
│   ├── stg_regulations.sql
│   ├── stg_access_tiers.sql
│   ├── stg_manufacturers.sql
│   ├── stg_attribute_battery_type_mapping.sql
│   ├── stg_attribute_regulation_mapping.sql
│   └── stg_manufacturer_disclosures.sql
├── intermediate/     # business logic, derived columns
│   └── int_attributes_enriched.sql   # adds complexity_score
└── marts/            # final, analysis-ready tables
    ├── mart_act1_reach.sql
    ├── mart_act2_complexity.sql
    ├── mart_act3_transparency.sql
    └── mart_act4_industry_position.sql
```

## Naming conventions

- `stg_` — staging models, 1:1 with raw sources
- `int_` — intermediate models with derived logic
- `mart_` — final marts consumed by Tableau / notebooks
- snake_case throughout

## Tests

Every model should have at minimum:
- `not_null` and `unique` on primary keys
- `relationships` test on foreign keys
- `accepted_values` on categorical columns

See `models/schema.yml` for the test definitions.

## Documentation

`dbt docs generate && dbt docs serve` produces an interactive lineage graph.
Take a screenshot for the report.
