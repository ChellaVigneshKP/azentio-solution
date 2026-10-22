## Smart Dispute & Refund Orchestrator (DB-First)

---

## 📌 Overview

**Smart Dispute & Refund Orchestrator** is an end-to-end fintech application built with a **DB-first architecture**, where **PostgreSQL is the system of record and the single source of truth for business rules**.

All core business logic — **eligibility validation, decision routing, refund processing, and audit tracking** — is implemented at the **database layer using stored procedures and functions**, and exposed via a **Spring Boot REST API**.
A **Next.js frontend** consumes only REST APIs and demonstrates the complete workflow.

---

## 🧠 Key Design Principle

> **Business rules live in the database, not in the API or UI.**

* API layer is a thin orchestration layer
* UI never directly accesses the database
* Immutable audit trail maintained at DB level

---

## 🏗️ Architecture

```
[ Next.js UI ]
      |
      v
[ Spring Boot REST API ]
      |
      v
[ PostgreSQL ]
  - Tables
  - Functions
  - Procedures
  - Triggers (Audit)
```

---

## 📂 Project Structure

```
azentio-solution/
│
├── setup.sh                     # One-command setup (DB + Backend + Frontend)
├── README.md
├── postman/
│   └── dispute-orchestrator.postman_collection.json
│
├── database/
│   ├── setup_db.sql
│   ├── dispute_orchestrator_schema.sql
│   ├── seed_dispute_type.sql
│   ├── stored_procedures.sql
│   └── seed_db.sql
│
├── backend/
│   ├── pom.xml
│   ├── src/main/java/com/chellavignesh/azentiosolution
│   └── src/main/resources/application.yml
│
├── frontend/
│   ├── package.json
│   ├── src/
│   └── app/
│
└── screenshots/                 # Optional UI screenshots
```

---

## 🗄️ Database Layer (Mandatory)

### Tables

* `customer`
* `account`
* `txn`
* `dispute`
* `dispute_event` (immutable audit trail)
* `refund`
* `dispute_type_rule`
* `dispute_status_history`

### Stored Functions

* `fn_is_dispute_eligible(txn_id, dispute_type)`
* `fn_route_dispute_decision(dispute_id)`

### Stored Procedures

* `sp_create_dispute(...)`
* `sp_decide_dispute(...)`
* `sp_issue_refund(...)`

### Triggers

* Automatic dispute status audit on every status change

📌 **All validations and decisions are enforced in the database.**

---

## 🔁 Business Rules Implemented

### Eligibility Window

| Dispute Type          | Days |
| --------------------- | ---- |
| DUPLICATE_CHARGE      | 30   |
| SERVICE_NOT_DELIVERED | 15   |
| WRONG_AMOUNT          | 7    |
| FRAUD_SUSPECTED       | 60   |

### Decisioning

* Txn status `REVERSED` / `CHARGEBACK_DONE` → **REJECT**
* KYC ≠ `FULL` → **MANUAL REVIEW**
* Claim amount > threshold → **MANUAL REVIEW**
* FRAUD_SUSPECTED → **MANUAL REVIEW**
* Otherwise → **AUTO APPROVE**

---

## 🌐 REST API Layer (Mandatory)

### Base URL

```
http://localhost:6060
```

### Endpoints

| Method | Endpoint                    | Description               |
| ------ | --------------------------- | ------------------------- |
| POST   | `/disputes`                 | Create dispute            |
| GET    | `/disputes?custId=&status=` | Search disputes           |
| GET    | `/disputes/{id}`            | Dispute details           |
| POST   | `/disputes/{id}/decision`   | Approve / Reject / Manual |
| POST   | `/disputes/{id}/refund`     | Issue refund              |
| GET    | `/health/db`                | DB connectivity check     |

### API Docs

```
http://localhost:6060/swagger-ui.html
```

---

## 🖥️ Web UI (Optional – Implemented)

### Features

* Create dispute
* View disputes by customer & status
* Dispute detail view
* Decision & refund actions
* DB health indicator

### UI URL

```
http://localhost:3000
```

📌 UI communicates **only via REST APIs**, no direct DB access.

---

## 🚀 How to Run the Application

### Prerequisites

* Java 21+
* Maven
* Node.js 18+
* PostgreSQL
* npm

### One-Command Setup

```bash
chmod +x setup.sh
./setup.sh
```

### What This Does

* Creates DB & user
* Runs all SQL scripts
* Builds & starts Spring Boot backend
* Installs & starts Next.js frontend

---

## 🧪 Testing the Solution

### API Testing

* Import Postman collection from `/postman`
* Or use Swagger UI

### Sample Curl

```bash
curl "http://localhost:6060/disputes?custId=1"
```

### Database Verification

```sql
SELECT * FROM dispute_event ORDER BY created_at;
SELECT * FROM dispute_status_history;
```

---

## 🛡️ Audit & Data Integrity

* All state transitions recorded in `dispute_event`
* Status changes tracked in `dispute_status_history`
* Refund constrained to **one per dispute**
* DB constraints prevent invalid state transitions
* Audit & Data Integrity
