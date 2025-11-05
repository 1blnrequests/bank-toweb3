# Digital Banking Platform — Infrastructure as Code (IaC) - Architect Side - Roughly Version

This repository defines the **infrastructure and deployment automation** for a modern digital bank, using **Terraform**, **Helm**, and **ArgoCD** within a **GitOps** workflow.

---

## Architecture Overview
- **Hybrid control plane:** AWS provides elastic EKS, managed Kafka, and control-plane guardrails, while on-prem vSphere workloads host confidential compute and deterministic-latency services.
- **Private object storage:** MinIO underpins sovereign evidence retention with S3-compatible replication policies across the hybrid estate.
- **Core Infrastructure:** VPC, Kubernetes clusters, Vault, Kafka, PostgreSQL.
- **Banking Microservices:** Customer onboarding, accounts, payments, lending, compliance, analytics, and channel integrations.
- **CI/CD Pipeline:** GitHub Actions + ArgoCD for automated reconciliation of infrastructure and application manifests.
- **Secrets Management:** HashiCorp Vault with strict audit logging and just-in-time secrets delivery.
- **Integration Fabric:** REST and gRPC APIs complemented by Kafka topics for event-driven choreography.

![GitOps diagram](https://github.com/1blnrequests/bank-toweb3/blob/main/docs/diagrams/gitops_model.png)
The diagram illustrates the delivery pipeline: Developers push to GitHub → Actions trigger Terraform/Helm → ArgoCD syncs to Kubernetes → Regulated services are deployed with observability in place.

> **Need the bigger picture?** Review the [Hybrid Web3 Integration Blueprint](docs/architecture/hybrid-web3.md) for TOGAF-aligned governance, capability heatmaps, and ArchiMate diagrams curated for the architecture board.

---

## Core API Domains
Our banking platform prioritises customer-centric APIs while remaining compliant with regulations such as **GDPR**, **PSD2**, **AML**, and **KYC**. Each API is OAuth2-enabled with contextual enhancements (mTLS, biometric challenges, RBAC) as required.

### Customer Onboarding & KYC API
- Digital account origination with electronic KYC workflows.
- Integrations with identity providers (e.g., Jumio, Onfido) and consent management for GDPR.
- Risk-based screening, MFA enrolment, and profile lifecycle management.

### Accounts & Balances API
- Account opening/closure, balance inquiries, and transaction history across savings, checking, and joint accounts.
- Supports real-time transfers (SEPA, SWIFT, ACH) including overdraft handling and notifications.
- Integrates with core ledger, payment gateway, and fraud detection engines.

### Payments & Transfers API
- Domestic and cross-border payment initiation aligned with PSD2 AIS/PIS requirements.
- Batch payroll, standing orders, direct debits, and FX conversions with live rates.
- Strong Customer Authentication (SCA) with mutual TLS for partner integrations.

### Lending & Credit API
- Loan applications, eligibility checks, and automated credit scoring.
- Disbursement tracking, repayment schedules, and refinancing workflows.
- Connects to risk engines, bureaus (Equifax, Experian), and reporting services.

### AML & Compliance Rules Engine API
- Real-time transaction screening against sanction lists (OFAC, EU, UN).
- Customer due diligence (CDD/EDD), source of funds verification, and monitoring API.
- Kafka-driven alerts with immutable audit logs for freezes and manual reviews.

### Risk & Fraud Scoring API
- Machine-learning powered transaction and behavioural risk analysis.
- gRPC endpoints for low-latency scoring with encrypted payloads.
- Feeds analytics platforms and fraud alerting topics.

### Card Management API
- Issuance of physical and virtual cards, activation, and personalisation.
- PIN management, limits, blocking/unblocking, and dispute handling.
- Tokenisation for Apple Pay / Google Pay and network settlement integration.

### Treasury & Liquidity Management API
- Currency reserve tracking, cash pooling, hedging operations, and stress testing.
- Inter-account transfers across treasury accounts with market data integrations.
- RBAC enforced with full audit trails.

### Data Analytics & Reporting API
- KPI dashboards (acquisition, churn, transaction volumes) and regulatory reports (FATCA, CRS, PSD2 metrics).
- Data exports to warehouses (BigQuery, Snowflake) and support for BI tooling.
- Encrypted data delivery with scoped OAuth2 tokens.

### Developer Portal & Open Banking API
- API key management, sandbox onboarding, SDK generation, and consent APIs.
- Rate limits, usage analytics, and marketplace integrations for fintech partners.

### Investment & Wealth Management API
- Portfolio tracking for mutual funds, equities, and robo-advisory recommendations.
- Risk profiling, rebalancing, and tax reporting.
- Integrations with exchanges, fund providers, and compliance controls.

### Customer Support & Notifications API
- Omnichannel support via chatbots, ticketing, and FAQ services.
- Push/SMS/email notifications for transactions, alerts, and marketing.
- Feedback capture with sentiment analysis tied into CRM systems.

### Branch & ATM Integration API
- Branch/ATM locator, appointment scheduling, queue management, and IoT telemetry.
- Tracks cash deposits/withdrawals to synchronise physical and digital channels.
- OAuth2 with device binding for secure terminal integrations.

---

## Kafka Streaming Topics
Events follow the naming convention `corebank.[domain].[event].v1` to support discoverability and schema evolution. Key streams include:

- `corebank.customer.onboarded.v1` – New customer registrations, KYC approvals, account provisioning.
- `corebank.accounts.balance.updated.v1` – Real-time balance adjustments from deposits, withdrawals, interest.
- `corebank.payments.initiated.v1` – Payment creation events across domestic and international rails.
- `corebank.payments.confirmed.v1` – Settled payments with fees and settlement metadata.
- `corebank.lending.applications.submitted.v1` – Loan submissions with preliminary scoring results.
- `corebank.lending.disbursed.v1` – Loan disbursements and repayment schedule activation.
- `corebank.aml.alerts.v1` – Compliance alerts for suspicious activities or escalations.
- `corebank.fraud.detected.v1` – Fraud model detections, blocked transactions, device fingerprinting.
- `corebank.cards.issued.v1` – Card issuance, activation, replacement workflow notifications.
- `corebank.cards.transactions.v1` – Card authorisations, declines, chargebacks.
- `corebank.treasury.liquidity.updated.v1` – Liquidity pool changes, FX rate updates, reserve movements.
- `corebank.analytics.metrics.v1` – Business metrics (DAU, churn, transaction volumes).
- `corebank.notifications.sent.v1` – Notification dispatch confirmations per customer channel.
- `corebank.regulatory.reports.v1` – Regulatory filing payloads (AML reports, statements).
- `corebank.operations.audits.v1` – System audits, access control changes, error events.
- `corebank.customer.behavior.updated.v1` – Behavioural analytics for personalisation (logins, spending patterns).
- `corebank.investments.orders.executed.v1` – Executed investment trades with market confirmations.
- `corebank.support.tickets.created.v1` – Customer support ticket openings and escalations.

All topics apply 14-day retention with schema governance, Prometheus-backed observability, and consumer groups tailored per domain.

---

## Environments
| Environment | Description | Deployment Method |
|-------------|-------------|-------------------|
| Sandbox     | Isolated integration environment | Automated Terraform plan & ArgoCD sync |
| Staging     | Pre-production validation | ArgoCD sync with change approvals |
| Production  | Regulated deployment | Manual GitOps promotion with four-eyes review |

---

## Stack Summary
| Layer | Tool | Purpose |
|-------|------|----------|
| Infrastructure | Terraform | Declarative cloud resources |
| Configuration | Helm | Kubernetes manifests |
| Delivery | ArgoCD | GitOps sync & drift detection |
| Security | Vault + HSM | Secrets management, key custody |
| Messaging | Kafka | Event-driven integration |
| CI/CD | GitHub Actions | Terraform plan/apply, Helm lint/deploy |

![Before](https://github.com/1blnrequests/bank-toweb3/blob/main/docs/diagrams/before-web3.png)
![After](https://github.com/1blnrequests/bank-toweb3/blob/main/docs/diagrams/after-web3.png)
---

## Security & Compliance Principles
- **Zero Trust** networking with service-to-service mTLS and policy enforcement.
- **Regulatory alignment** for GDPR, PSD2, AML/KYC with auditable access trails.
- **Immutable environments** managed via Git with change control gates.
- **Continuous monitoring** via Prometheus, Grafana, and SIEM integrations.

---

## How to Deploy
### Prerequisites
- Cloud account with IAM permissions for Terraform.
- GitHub secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `TF_VAR_vault_token` (or cloud equivalent).
- Local tooling: `kubectl`, `helm`, `terraform`, and ArgoCD CLI.

```bash
# 1. Clone repo
git clone https://github.com/your-org/digital-bank-infra.git
cd digital-bank-infra

# 2. Terraform Init
cd terraform
terraform init
terraform workspace select sandbox

# 3. Plan Infrastructure
terraform plan -var-file=env/sandbox.tfvars

# 4. Apply after approval
terraform apply -var-file=env/sandbox.tfvars

# 5. Deploy Helm charts via ArgoCD
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application.yaml

# 6. Monitor in ArgoCD UI
argocd app sync digital-bank-platform
```
