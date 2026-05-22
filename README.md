# IPC Fabric Demo - dbt + GitHub + Fabric

Demonstrates dbt managing a Fabric Warehouse with GitHub Actions CI/CD.

## Architecture

```
Seeds (CSV) → Staging (views) → Marts (tables)
     ↓              ↓                ↓
  raw_*        stg_*           dim_* / fct_*
```

## Models

### Staging (views)
- `stg_customers` - cleaned customer data
- `stg_service_orders` - cleaned service order data
- `stg_billing` - cleaned billing data

### Marts (tables)
- `dim_customers` - customer dimension with aggregated metrics
- `fct_service_orders` - service orders enriched with customer info
- `fct_billing_summary` - billing summary per customer

## Setup

1. Install dbt-fabric: `pip install dbt-fabric`
2. Copy `profiles.yml.example` to `~/.dbt/profiles.yml`
3. Update server/database with your Fabric Warehouse connection
4. Run `az login` (uses Azure CLI auth locally)
5. Run `dbt seed` to load sample data
6. Run `dbt build` to create all models

## CI/CD

GitHub Actions runs on PR and push to main:
- Installs dbt-fabric
- Connects to Fabric Warehouse via Service Principal
- Runs seed → build → test

## Connection

Uses `dbt-fabric` adapter with:
- Local dev: Azure CLI authentication (`az login`)
- CI/CD: Service Principal authentication (GitHub secrets)
