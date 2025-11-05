# Core Banking Event Streams

This document outlines the integration contracts between the bank's core platforms and downstream services. It focuses on the API calls and Kafka topics that support customer onboarding, payments, lending, compliance, and analytics in a fully digital bank.

## Overview
- **Producers:** Customer onboarding, payments, lending, treasury, compliance, card issuing, and support platforms.
- **Consumers:** Core banking microservices, risk & fraud engines, reporting/analytics platforms, notification services, and developer portal integrations.
- **Transport:** HTTPS (REST/GraphQL), gRPC for low-latency scoring, and Apache Kafka (Avro/JSON) for event-driven distribution.

## API Integrations
| Domain | Base URL | Auth Profile | Purpose |
|--------|----------|--------------|---------|
| Customer Onboarding | `https://api.bank.local/onboarding` | OAuth2 + JWT + biometric challenge | Register customers, capture KYC artefacts, manage consent. |
| Accounts & Balances | `https://api.bank.local/accounts` | OAuth2 client credentials | Retrieve balances, transactions, overdraft status in real time. |
| Payments & Transfers | `https://api.bank.local/payments` | PSD2 SCA + mTLS | Initiate domestic/international payments, manage standing orders. |
| Lending & Credit | `https://api.bank.local/lending` | OAuth2 + RBAC | Submit loan applications, retrieve offers, manage repayment schedules. |
| AML Rules Engine | `https://api.bank.local/aml` | mTLS + audit headers | Screen customers/transactions, manage alerts, trigger freezes. |
| Risk & Fraud Scoring | `grpc://risk.bank.local` | OAuth2 + payload encryption | Real-time transaction and behavioural scoring via ML models. |
| Card Management | `https://api.bank.local/cards` | SCA + hardware tokens | Issue, activate, block cards, manage disputes and tokenisation. |
| Treasury & Liquidity | `https://api.bank.local/treasury` | RBAC + audit trails | Manage liquidity positions, FX trades, and hedging actions. |
| Data & Reporting | `https://api.bank.local/analytics` | OAuth2 + data encryption | Access dashboards, metrics, regulatory reports, and exports. |
| Developer Portal | `https://developers.bank.local` | OAuth2 + consent tokens | Manage API keys, sandbox usage, and partner onboarding. |
| Customer Support | `https://api.bank.local/support` | JWT + session tokens | Create tickets, manage omnichannel conversations, deliver notifications. |
| Branch & ATM | `https://api.bank.local/branch-atm` | OAuth2 + device binding | Synchronise appointments, queue status, and IoT telemetry. |

## Kafka Topics
| Topic | Owner | Key Payload Fields | Consumer Notes |
|-------|-------|--------------------|----------------|
| `corebank.customer.onboarded.v1` | Onboarding | `customerId`, `kycStatus`, `segment`, `createdAt` | Triggers account provisioning, welcome journeys. |
| `corebank.accounts.balance.updated.v1` | Accounts | `accountId`, `balance`, `currency`, `available`, `timestamp` | Drives balance refresh, notifications, and liquidity views. |
| `corebank.payments.initiated.v1` | Payments | `paymentId`, `customerId`, `amount`, `currency`, `scheme`, `createdAt` | Downstream AML and risk scoring subscribe for screening. |
| `corebank.payments.confirmed.v1` | Payments | `paymentId`, `status`, `settledAt`, `fees`, `exchangeRate` | Ledger and analytics consume for reconciliation. |
| `corebank.lending.applications.submitted.v1` | Lending | `applicationId`, `customerId`, `product`, `score`, `submittedAt` | Risk engine enriches and compliance monitors exposure. |
| `corebank.lending.disbursed.v1` | Lending | `loanId`, `disbursedAmount`, `schedule`, `interestRate`, `disbursedAt` | Treasury and accounting update funding positions. |
| `corebank.aml.alerts.v1` | Compliance | `alertId`, `entityId`, `severity`, `reason`, `createdAt` | Case management and regulatory reporting consume for workflows. |
| `corebank.fraud.detected.v1` | Risk & Fraud | `eventId`, `customerId`, `score`, `decision`, `timestamp` | Triggers holds, customer notifications, and audit logging. |
| `corebank.cards.issued.v1` | Cards | `cardId`, `customerId`, `type`, `status`, `issuedAt` | Notification service and CRM initiate onboarding messages. |
| `corebank.cards.transactions.v1` | Cards | `transactionId`, `amount`, `currency`, `merchant`, `decision` | Fraud scoring enriches with behavioural data. |
| `corebank.treasury.liquidity.updated.v1` | Treasury | `portfolioId`, `currency`, `liquidity`, `updatedAt` | Treasury dashboards and forecasting tools consume for stress tests. |
| `corebank.analytics.metrics.v1` | Analytics | `metric`, `value`, `dimension`, `capturedAt` | Feeds data lake and executive dashboards. |
| `corebank.notifications.sent.v1` | Notifications | `messageId`, `channel`, `status`, `sentAt`, `correlationId` | Ensures audit of customer communications. |
| `corebank.regulatory.reports.v1` | Compliance | `reportId`, `type`, `period`, `submittedAt`, `status` | Regulatory portal builds filings and evidence bundles. |
| `corebank.operations.audits.v1` | Platform Ops | `eventId`, `user`, `action`, `resource`, `timestamp` | Security teams monitor configuration and access changes. |
| `corebank.customer.behavior.updated.v1` | Analytics | `customerId`, `event`, `channel`, `attributes`, `occurredAt` | Personalisation and marketing automation use for campaigns. |
| `corebank.investments.orders.executed.v1` | Investments | `orderId`, `instrument`, `quantity`, `price`, `executedAt` | Portfolio service updates holdings and tax lots. |
| `corebank.support.tickets.created.v1` | Support | `ticketId`, `customerId`, `channel`, `priority`, `createdAt` | Support dashboards track SLAs and escalations. |

## Sequence Snapshot
1. **Customer onboarded** → Onboarding service emits `corebank.customer.onboarded.v1` → Accounts service provisions core banking accounts.
2. **Payment initiated** → Payments API validates SCA → emits `corebank.payments.initiated.v1` → AML and fraud services perform screening.
3. **Loan approved** → Lending service publishes `corebank.lending.disbursed.v1` → Treasury adjusts liquidity and analytics update exposure.
4. **Card transaction scored** → Card network posts to `corebank.cards.transactions.v1` → Fraud scoring enriches and may emit alerts.
5. **Notification delivered** → Notification service confirms via `corebank.notifications.sent.v1` → Support portal reflects customer communication history.

## Retention & Observability
- Kafka topics use a **14-day retention** policy with schema validation and compatibility checks.
- APIs emit **structured audit logs** forwarded to the bank's SIEM and observability stack.
- Prometheus and Grafana expose metrics: API latency buckets, Kafka lag, onboarding conversion, and fraud detection accuracy.

## Implementation Notes
- Dedicated consumer groups per domain ensure isolation (e.g., `fraud-ml`, `reg-reporting`, `developer-portal`).
- Schema evolution managed via Confluent Schema Registry (`schemareg.bank.local`) with backward compatibility testing.
- Secrets for API clients and Kafka credentials sourced from Vault paths under `secret/data/platform/corebank`.
