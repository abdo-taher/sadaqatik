# Charity / Donations Financial Platform – Saved Point

## 🚀 Overview
- **Architecture:** Modular Monolith, Microservice-ready
- **Pattern:** Event-Driven, Async-first, CQRS, Hexagonal / Clean Architecture
- **Audit-first:** Immutable Audit Logs
- **Financial Rules:** Double-entry Ledger, Zakat 2.5%, Multi-Currency, Budget Thresholds
- **Phase-aware:** 1 → 10, cannot skip phases

---

## 🧩 Modules & Phases Status

| Phase | Module | Status | Key Features Implemented |
|-------|--------|--------|-------------------------|
| 1 | Core / Ledger | ✅ Done | Double-entry Ledger, LedgerEntry, Balances Projection, Audit integration |
| 2 | Projects | ✅ Done | CRUD Projects, linked to Organizations, Donor / Committee mapping |
| 3 | Donations | ✅ Done | CreateDonationCommand, DonationConfirmed Event, LedgerEntry, Audit, Zakat |
| 4 | Allocation | ✅ Done | CreateAllocationCommand triggered by DonationConfirmed Event |
| 5 | Spending | ✅ Done | SpendingApproved Event, Projection updates for Committee & Finance Dashboards |
| 6 | Forecast / Budget | ✅ Done | Budget Thresholds, Forecast Projections, Notifications |
| 7 | Zakat | ✅ Done | Auto-calculation 2.5% on Donations / Allocations, ZakatCalculated Event |
| 8 | Audit | ✅ Done | Immutable Audit Logs, AuditLogged Event, wildcard + type-safe listener ready |
| 9 | Payments | ⏳ Pending | ProcessPaymentCommand, PaymentConfirmed Event, Ledger/Audit/Zakat integration |
| 10 | Dashboard / Tracking | ⏳ Pending | Read Models ready, UI integration pending, WebSocket real-time updates |

---

## 👥 User Roles & Status

| Role | Flow Implemented | Status |
|------|-----------------|--------|
| Donor | View Organizations → View Projects → Donate → Payment → Dashboard | ✅ Viewer / Explorer ready |
| Committee Member | Manage Allocations → Approve Spending → Dashboard | ✅ Projection ready |
| Finance Officer | Ledger, Payments, Zakat, Forecast → Dashboard | ✅ Projection ready |
| Admin | Full System View → Audit Logs → Dashboard | ✅ Projection ready |
| Auditor | Audit Logs → Ledger & Zakat Verification → Dashboard | ✅ Projection ready |

---

## 🔁 Event Flow Overview

DonationCreated → DonationConfirmed  
↓  
ProcessPaymentCommand → PaymentConfirmed  
↓  
LedgerEntry (Debit / Credit)  
↓  
AuditLogged  
↓  
ZakatCalculated  
↓  
CreateAllocationCommand → AllocationCreated  
↓  
SpendingApproved → Committee & Finance Dashboards  
↓  
Forecast / Budget Checks → FinanceDashboard / Notifications

- All events **async**, **immutable**, **microservice-ready**  
- No Module reads another Module’s DB  
- Phase-aware: no skipping

---

## ✅ Completed

- Core Modules (Ledger, Projects, Donations, Allocation, Spending, Forecast, Zakat, Audit) implemented  
- Donor / Committee / Finance / Admin / Auditor Read Models ready  
- AuditListener fixed for wildcard type safety  
- EventBus ready for async communication  
- Zakat, Ledger, and Audit fully integrated  
- Donor Viewer / Explorer flows working

---

## ⏳ Pending / Next Steps

1. **Payments Module**: integrate ProcessPaymentCommand + PaymentConfirmed Event fully  
2. **Dashboard UI**: connect Read Models + WebSockets for live updates  
3. **Admin / Auditor UI**: full visualization of AuditLogs + Ledger + Zakat  
4. **Swagger / API Docs**: finalize for all controllers & endpoints  
5. **Testing**: integration tests for cross-module Event flows  
6. **Deployment**: Docker / Kubernetes setup for async & scalable environment

---

> 🔖 This SAVED_POINT.md is a **Saved Point** for the current project state.  
> All completed Phases, Modules, User Flows, and Event connections are documented here for reference before continuing development.

