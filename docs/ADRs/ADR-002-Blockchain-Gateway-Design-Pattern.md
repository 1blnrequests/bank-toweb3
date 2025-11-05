# ADR-002: Blockchain Gateway Design Pattern

## Status
Accepted

## Context
The integration of Web3 capabilities requires a unified, secure, and abstracted interface to interact with multiple blockchain networks (e.g., Ethereum, Solana, Polygon) without exposing internal services to raw RPC endpoints or network-specific complexities. The bank lacks existing blockchain connectivity, and direct integrations would introduce risks such as node outages, varying APIs, security vulnerabilities (e.g., exposed keys), and maintenance overhead for reorgs, gas management, and event subscriptions. The gateway must support read/write operations, event listening, and integrations with custody, ledger, and AML components while adhering to regulatory standards for auditability, retry logic, and idempotency.

Key challenges:
- **Multi-Chain Support**: Handle EVM-compatible and non-EVM chains with a single API to future-proof expansions (e.g., L2 rollups, zk-proofs).
- **Reliability and Performance**: Manage nonce conflicts, gas optimization, transaction retries, and failover across node providers to ensure high availability in a banking context.
- **Security**: Prevent direct exposure to external nodes; enforce mTLS, rate limiting, and integration with HSM/MPC for signing.
- **Compliance**: Log all interactions for audits; integrate with AML Adapter for on-chain risk checks before broadcasting.
- **Event-Driven Alignment**: Stream on-chain events (e.g., logs, confirmations) to Kafka topics for reconciliation and notifications.
- **Extensibility**: Allow easy addition of new chains or providers without redeploying core services.
- **Cost Efficiency**: Optimize for minimal on-chain calls, especially in pooled custody models.

The gateway acts as a core component in the Web3 domain, bridging the Blockchain Access Layer with internal services like Custody and DeFi Orchestration.

## Decision
We will implement the **Blockchain Gateway** as an abstract microservice layer using a facade design pattern, providing a unified REST/gRPC API over heterogeneous blockchain RPC nodes. It will connect to multiple providers (e.g., Infura, Alchemy, or self-hosted nodes) via secure VPN/private links, with built-in features for transaction management, event subscription, and error handling.

Key elements:
- **API Interface**: REST/gRPC endpoints for operations like `sendTransaction`, `getBalance`, `queryContract`, `subscribeEvents`. Use protobuf schemas for gRPC efficiency in high-throughput scenarios.
- **Provider Abstraction**: Adapter pattern for chain-specific clients (e.g., web3.js for EVM, solana-web3.js for Solana); dynamic routing based on chain ID.
- **Transaction Handling**: Idempotent processing with nonce management, gas estimation/optimization, and retry queues (integrated with Kafka dead-letter topics).
- **Event Monitoring**: WebSocket subscriptions for logs/topics; block scanners for guaranteed delivery during reorgs; events published to Kafka (e.g., `corebank.crypto.tx.confirmed.v1`).
- **Security and Compliance**: mTLS for provider connections; integration with AML Adapter for pre-broadcast screening; full logging to SIEM; rate limiting and circuit breakers.
- **Failover and Resilience**: Multi-provider setup with health checks; fallback to secondary nodes; configurable timeouts and retries.
- **Deployment**: As a stateless microservice in Kubernetes, scaled horizontally; provisioned via Terraform and deployed with Helm/ArgoCD.
- **Monitoring**: Prometheus metrics for latency, error rates, and chain health; alerts on drift or outages.

This pattern ensures loose coupling, allowing the bank to swap providers or add chains without impacting upstream services.

## Alternatives Considered
1. **Direct RPC Integrations per Service**:
   - Pros: Simple for small-scale; no intermediary overhead.
   - Cons: Duplicates code across services (e.g., Custody and DeFi both handling RPC); increases security risks and maintenance. Rejected due to violation of DRY principle and scalability issues.

2. **Third-Party Gateway Only (e.g., Infura API Directly)**:
   - Pros: Quick setup; managed reliability.
   - Cons: Vendor lock-in; limited customization for banking needs (e.g., custom AML hooks); potential latency/compliance gaps. Rejected for lack of control, with providers used as backends instead.

3. **Message Queue Proxy (e.g., Kafka as Gateway)**:
   - Pros: Fully event-driven; good for async ops.
   - Cons: Not suitable for synchronous queries (e.g., getBalance); adds complexity for real-time interactions. Rejected as it doesn't cover all use cases.

4. **GraphQL Federation**:
   - Pros: Flexible querying across chains.
   - Cons: Overkill for transaction-focused ops; performance overhead for mutations. Considered for future analytics but not primary gateway.

The facade pattern was selected for its balance of abstraction, performance, and alignment with microservices architecture.

## Consequences
### Positive
- **Unified Access**: Simplifies integrations for domains like Custody (e.g., seamless signing via HSM) and Ledger (e.g., auto-reconciliation).
- **Resilience**: Provider failover reduces downtime; idempotency handles network flakiness in Web3.
- **Compliance Gains**: Centralized logging and screening enforce AML/KYC; easier audits with standardized APIs.
- **Extensibility**: Adding new chains involves only adapter updates; supports rollups/L2 bridges natively.
- **Efficiency**: Gas optimizations reduce costs; batching in pooled models scales for retail banking.

### Negative
- **Added Latency**: Extra hop for requests; mitigated by caching (e.g., Redis for read queries) and gRPC streaming.
- **Complexity**: Managing adapters for non-EVM chains; addressed with phased rollout (EVM-first).
- **Dependency Risks**: Gateway as single point; mitigated by HA clustering and bypass options for critical paths.
- **Development Overhead**: Initial adapter implementation; offset by SDK reuse (e.g., web3 libraries).

## Compliance
This design complies with:
- **Regulatory Standards**: Supports on-chain attestation via integrations with Chainalysis/TRM; transaction logs for FATF/OFAC screening.
- **Security**: Aligns with zero-trust via mTLS and Vault; audited for key exposure risks.
- **Standards**: Follows BIAN for integration layers and C4 for modeling.

## Related Decisions
- ADR-001: Domain-Aligned Microservices Architecture (Gateway as Web3 domain component).
- ADR-007: Custody Model (transaction signing integration).
- ADR-005: Web3 Ledger and Reconciliation Approach (event streaming).

## Notes
Decision ratified in Architecture Board meeting on November 04, 2025, with feedback from Blockchain leads, CISO, and Compliance. Prototype validated with Ethereum testnet. Review post-Phase 1 or upon adding non-EVM chains.