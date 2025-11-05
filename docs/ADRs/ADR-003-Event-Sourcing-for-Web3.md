# ADR-003: Event Sourcing for Web3 Ledger Reconciliation

## Status
Accepted

## Context
The Web3 integration requires accurate, auditable reconciliation between on-chain states (e.g., blockchain balances, transaction confirmations) and off-chain systems (e.g., Web3 Sub-Ledger and Core Banking). Blockchain networks introduce challenges like eventual consistency, chain reorganizations (reorgs), asynchronous events, and probabilistic finality, which can lead to discrepancies if not handled properly. Traditional polling or snapshot-based approaches risk data loss, high latency, or incomplete histories, especially in a regulated banking environment where every transaction must be traceable for compliance (e.g., AML, GAAP/IFRS reporting) and risk management.

Key challenges:
- **Consistency Across Layers**: Ensure tri-layer reconciliation (on-chain → Web3 Ledger → Core Banking) without gaps, handling reorgs where blocks/transactions may be invalidated.
- **Auditability and Immutability**: Maintain an immutable event trail for regulatory audits, dispute resolution, and forensic analysis.
- **Scalability**: Process high-volume on-chain events (e.g., logs from smart contracts) in real-time without overloading the system.
- **Resilience**: Handle network outages, delayed confirmations, or provider failures with retries and idempotency.
- **Integration with Architecture**: Align with Kafka-based event-driven design, feeding into domains like AML Adapter (for risk scoring) and Treasury (for liquidity updates).
- **Data Integrity**: Map on-chain events (e.g., ERC-20 transfers, mint/burn) to бухгалтерские postings in the ledger, supporting pooled/sub-account models.
- **Regulatory Demands**: Support reports for MiCA/AML6, with timestamps, hashes, and proofs.

The reconciliation mechanism is central to the Web3 Ledger Service, ensuring the bank treats digital assets as reliable as fiat entries.

## Decision
We will adopt **event sourcing** as the core pattern for Web3 Ledger reconciliation, treating on-chain events as the source of truth for state reconstruction. All blockchain interactions (via the Gateway) will generate immutable events stored in Kafka topics, which are then processed to build and update the ledger state in a queryable database (e.g., PostgreSQL).

Key elements:
- **Event Capture**: Blockchain Gateway subscribes to logs/topics and block events; publishes raw events to Kafka (e.g., `corebank.crypto.tx.submitted.v1`, `corebank.crypto.tx.confirmed.v1`) with metadata (chain ID, tx hash, block number, timestamp).
- **Event Storage**: Use Kafka as an immutable log (with infinite retention for audit topics); schema enforcement via Confluent Schema Registry.
- **State Reconstruction**: Event processors (e.g., Kafka Streams or Spring Cloud Stream) replay events to compute current state in the Web3 Ledger DB. Support snapshots for fast replays and projections for queries (e.g., client balances).
- **Reconciliation Engine**: Periodic jobs compare states: on-chain queries vs. ledger snapshots vs. Core Banking entries. Discrepancies trigger alerts or compensations (e.g., via sagas).
- **Handling Reorgs**: Monitor block depth/finality; use confirmation thresholds (e.g., 12 blocks for Ethereum); rewind and reprocess events on reorg detection.
- **Idempotency and Retries**: Events include unique IDs (e.g., tx hash + nonce); processors use outbox pattern to avoid duplicates.
- **Projections**: Materialized views for common queries (e.g., portfolio summaries); integrated with Analytics API for dashboards.
- **Deployment and Monitoring**: Processors as microservices in Kubernetes; metrics on event lag, reorg frequency, and reconciliation success rates.

This pattern ensures the ledger can be rebuilt from events at any time, providing resilience and auditability.

## Alternatives Considered
1. **Polling-Based Reconciliation**:
   - Pros: Simple to implement; no need for real-time subscriptions.
   - Cons: High latency (misses intra-block events); inefficient for high-frequency chains; risks missing reorgs. Rejected due to poor real-time performance in banking.

2. **Snapshot Sync with Periodic Checks**:
   - Pros: Low overhead for state queries; easy initial sync.
   - Cons: Lacks full history for audits; vulnerable to gaps during outages; doesn't handle event ordering well. Rejected for insufficient immutability.

3. **CQRS without Event Sourcing**:
   - Pros: Separates commands/queries for scalability.
   - Cons: Still requires a reliable event log; without sourcing, state recovery is harder post-failure. Considered complementary but insufficient alone.

4. **Blockchain-Specific Tools (e.g., The Graph for Indexing)**:
   - Pros: Optimized for on-chain querying.
   - Cons: Vendor/chain lock-in; external dependency increases compliance risks. Rejected in favor of internal Kafka for control.

Event sourcing was selected for its alignment with banking ledger principles (immutable transactions) and seamless Kafka integration.

## Consequences
### Positive
- **Reliability**: Full replayability ensures recovery from failures; handles reorgs gracefully.
- **Auditability**: Immutable Kafka logs serve as a tamper-proof record; easy export for regulators.
- **Scalability**: Parallel processing of streams; partitions by chain/client for load balancing.
- **Real-Time Insights**: Events trigger immediate updates (e.g., notifications via `corebank.notifications.events.v1`).
- **Extensibility**: Add new event types (e.g., for DeFi positions) without schema migrations.

### Negative
- **Storage Overhead**: Infinite retention increases Kafka costs; mitigated by compaction and tiered storage.
- **Complexity**: Event processors require careful design for idempotency; addressed with testing frameworks.
- **Latency in Replays**: Full replays during recovery; optimized with periodic snapshots.
- **Dependency on Kafka**: Outages affect reconciliation; mitigated by HA clusters and monitoring.

## Compliance
This approach complies with:
- **Regulatory Standards**: Supports source-of-funds tracing via event chains; aligns with FATCA/CRS for reporting.
- **Security**: Events encrypted in transit; access controlled via RBAC.
- **Standards**: Follows event sourcing patterns from DDD and aligns with C4 for component modeling.

## Related Decisions
- ADR-002: Blockchain Gateway Design Pattern (event capture source).
- ADR-007: Custody Model (transaction events from pooled wallets).
- ADR-001: Domain-Aligned Microservices Architecture (ledger as domain).

## Notes
Decision approved in Architecture Board meeting on November 04, 2025, with input from Data Architects, Compliance, and Web3 leads. Validated via proof-of-concept with Ethereum testnet events. Review after Phase 2 or upon high-volume testing.