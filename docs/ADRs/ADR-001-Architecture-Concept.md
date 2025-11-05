# ADR-001: Architecture Concept

## Context
Deliver a modular digital banking platform without disrupting incumbent core systems. Respect existing API gateways and Kafka buses owned by payments, onboarding, identity, compliance, treasury, and support teams while introducing new microservices for customer experiences.

## Decision
Adopt a domain-aligned microservices architecture. Each domain (onboarding, accounts, payments, lending, compliance, analytics, channels) owns its REST/gRPC interfaces and Kafka topics. Shared infrastructure (Terraform, Helm, ArgoCD, Vault, Kafka) provides consistent deployment, security, and observability.

## Status
Accepted
