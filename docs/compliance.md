# Compliance Notes

- **AML/KYC:** Integrate industry-standard screening (e.g., Dow Jones, Refinitiv) and identity verification partners (Jumio, Onfido) with continuous monitoring.
- **Regulations:** Align with GDPR, PSD2, FATCA/CRS, and local banking mandates for custody and reporting.
- **Audits:** All infrastructure and application changes are Git-audited; Terraform states stored in encrypted object storage with versioning.
- **Data lineage:** Kafka topics for core banking events retain 14 days of history with schema governance to satisfy regulatory traceability.
- **Privacy:** Enforce customer consent management, data minimisation, and right-to-be-forgotten workflows within onboarding and analytics services.
