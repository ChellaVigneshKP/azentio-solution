-- ============================
-- Drop objects (idempotent)
-- ============================

DROP TABLE IF EXISTS refund CASCADE;
DROP TABLE IF EXISTS dispute_event CASCADE;
DROP TABLE IF EXISTS dispute CASCADE;
DROP TABLE IF EXISTS txn CASCADE;
DROP TABLE IF EXISTS account CASCADE;
DROP TABLE IF EXISTS customer CASCADE;

-- ============================
-- CUSTOMER
-- ============================
CREATE TABLE customer
(
    cust_id    BIGSERIAL PRIMARY KEY,
    name       VARCHAR(120) NOT NULL,
    kyc_status VARCHAR(20)  NOT NULL
        CHECK (kyc_status IN ('NONE', 'PARTIAL', 'FULL')),
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================
-- ACCOUNT
-- ============================
CREATE TABLE account
(
    acct_id    BIGSERIAL PRIMARY KEY,
    cust_id    BIGINT         NOT NULL REFERENCES customer (cust_id),
    status     VARCHAR(20)    NOT NULL
        CHECK (status IN ('ACTIVE', 'SUSPENDED', 'CLOSED')),
    balance    NUMERIC(18, 2) NOT NULL DEFAULT 0,
    currency   VARCHAR(3)     NOT NULL DEFAULT 'INR',
    created_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================
-- TXN
-- ============================
CREATE TABLE txn
(
    txn_id     BIGSERIAL PRIMARY KEY,
    acct_id    BIGINT         NOT NULL REFERENCES account (acct_id),
    amount     NUMERIC(18, 2) NOT NULL CHECK (amount > 0),
    currency   VARCHAR(3)     NOT NULL DEFAULT 'INR',
    txn_ts     TIMESTAMP      NOT NULL,
    merchant   VARCHAR(120)   NOT NULL,
    status     VARCHAR(20)    NOT NULL
        CHECK (status IN ('SETTLED', 'REVERSED', 'CHARGEBACK_DONE')),
    created_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================
-- DISPUTE
-- ============================
CREATE TABLE dispute
(
    dispute_id   BIGSERIAL PRIMARY KEY,
    txn_id       BIGINT         NOT NULL REFERENCES txn (txn_id),
    cust_id      BIGINT         NOT NULL REFERENCES customer (cust_id),
    dispute_type VARCHAR(30)    NOT NULL,
    claim_amount NUMERIC(18, 2) NOT NULL CHECK (claim_amount > 0),
    status       VARCHAR(30)    NOT NULL
        CHECK (status IN (
                          'CREATED',
                          'PENDING_REVIEW',
                          'APPROVED',
                          'REJECTED',
                          'REFUND_INITIATED',
                          'REFUNDED'
            )),
    created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================
-- DISPUTE_EVENT (Audit Trail)
-- ============================
CREATE TABLE dispute_event
(
    event_id   BIGSERIAL PRIMARY KEY,
    dispute_id BIGINT      NOT NULL REFERENCES dispute (dispute_id),
    event_type VARCHAR(40) NOT NULL,
    actor      VARCHAR(80) NOT NULL,
    notes      VARCHAR(1000),
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================
-- REFUND
-- ============================
CREATE TABLE refund
(
    refund_id     BIGSERIAL PRIMARY KEY,
    dispute_id    BIGINT         NOT NULL REFERENCES dispute (dispute_id),
    refund_amount NUMERIC(18, 2) NOT NULL CHECK (refund_amount > 0),
    refund_ts     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    refund_status VARCHAR(30)    NOT NULL
        CHECK (refund_status IN ('INITIATED', 'COMPLETED', 'FAILED')),
    reference_no  VARCHAR(64)    NOT NULL
);

-- ============================
-- Indexes (Same as Oracle)
-- ============================
CREATE INDEX ix_dispute_txn_status
    ON dispute (txn_id, status);

CREATE INDEX ix_dispute_cust_status
    ON dispute (cust_id, status);

CREATE INDEX ix_event_dispute
    ON dispute_event (dispute_id, created_at);

ALTER TABLE refund
    ADD CONSTRAINT uq_refund_dispute UNIQUE (dispute_id);
