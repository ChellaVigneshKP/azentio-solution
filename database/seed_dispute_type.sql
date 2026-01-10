CREATE TABLE dispute_type_rule
(
    dispute_type        VARCHAR(30) PRIMARY KEY,
    eligibility_days    INT       NOT NULL,
    force_manual_review BOOLEAN   NOT NULL DEFAULT FALSE,
    max_auto_amount     NUMERIC(18, 2),
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO dispute_type_rule
VALUES ('DUPLICATE_CHARGE', 30, FALSE, 5000, CURRENT_TIMESTAMP),
       ('SERVICE_NOT_DELIVERED', 15, FALSE, 3000, CURRENT_TIMESTAMP),
       ('WRONG_AMOUNT', 7, FALSE, 2000, CURRENT_TIMESTAMP),
       ('FRAUD_SUSPECTED', 60, TRUE, NULL, CURRENT_TIMESTAMP);


CREATE TABLE dispute_status_history
(
    history_id BIGSERIAL PRIMARY KEY,
    dispute_id BIGINT      NOT NULL REFERENCES dispute (dispute_id),
    old_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by VARCHAR(80) NOT NULL,
    changed_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);
