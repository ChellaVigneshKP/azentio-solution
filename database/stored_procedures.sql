CREATE SCHEMA IF NOT EXISTS dispute_pkg;

CREATE OR REPLACE FUNCTION dispute_pkg.fn_is_dispute_eligible(
    p_txn_id BIGINT,
    p_dispute_type VARCHAR
) RETURNS BOOLEAN
    LANGUAGE plpgsql
AS $$
DECLARE
    v_txn_ts TIMESTAMP;
    v_days   INT;
BEGIN
    SELECT t.txn_ts, r.eligibility_days
    INTO v_txn_ts, v_days
    FROM txn t
             JOIN dispute_type_rule r
                  ON r.dispute_type = p_dispute_type
    WHERE t.txn_id = p_txn_id;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    RETURN (CURRENT_TIMESTAMP - v_txn_ts) <= (v_days || ' days')::INTERVAL;
END;
$$;


CREATE OR REPLACE FUNCTION dispute_pkg.fn_route_dispute_decision(
    p_dispute_id BIGINT
) RETURNS VARCHAR
    LANGUAGE plpgsql
AS $$
DECLARE
    v_claim_amount NUMERIC;
    v_kyc_status   VARCHAR;
    v_txn_status   VARCHAR;
    v_force_manual BOOLEAN;
    v_max_auto_amt NUMERIC;
BEGIN
    SELECT d.claim_amount,
           c.kyc_status,
           t.status,
           r.force_manual_review,
           r.max_auto_amount
    INTO v_claim_amount,
        v_kyc_status,
        v_txn_status,
        v_force_manual,
        v_max_auto_amt
    FROM dispute d
             JOIN customer c ON c.cust_id = d.cust_id
             JOIN txn t ON t.txn_id = d.txn_id
             JOIN dispute_type_rule r ON r.dispute_type = d.dispute_type
    WHERE d.dispute_id = p_dispute_id;

    -- Hard rejections
    IF v_txn_status IN ('REVERSED','CHARGEBACK_DONE') THEN
        RETURN 'REJECTED';
    END IF;

    -- Mandatory manual routing
    IF v_force_manual = TRUE OR v_kyc_status <> 'FULL' THEN
        RETURN 'PENDING_REVIEW';
    END IF;

    -- Amount-based routing
    IF v_max_auto_amt IS NOT NULL AND v_claim_amount > v_max_auto_amt THEN
        RETURN 'PENDING_REVIEW';
    END IF;

    RETURN 'APPROVED';
END;
$$;


CREATE OR REPLACE PROCEDURE dispute_pkg.sp_create_dispute(
    p_txn_id       BIGINT,
    p_cust_id      BIGINT,
    p_dispute_type VARCHAR,
    p_claim_amount NUMERIC,
    p_actor        VARCHAR
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_dispute_id BIGINT;
BEGIN
    IF NOT dispute_pkg.fn_is_dispute_eligible(p_txn_id, p_dispute_type) THEN
        RAISE EXCEPTION 'Dispute not eligible for given transaction';
    END IF;

    INSERT INTO dispute (
        txn_id, cust_id, dispute_type, claim_amount, status
    ) VALUES (
                 p_txn_id, p_cust_id, p_dispute_type, p_claim_amount, 'CREATED'
             )
    RETURNING dispute_id INTO v_dispute_id;

    INSERT INTO dispute_event(dispute_id, event_type, actor)
    VALUES (v_dispute_id, 'CREATED', p_actor);
END;
$$;


CREATE OR REPLACE PROCEDURE dispute_pkg.sp_decide_dispute(
    p_dispute_id BIGINT,
    p_actor      VARCHAR
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_new_status VARCHAR;
BEGIN
    v_new_status := dispute_pkg.fn_route_dispute_decision(p_dispute_id);

    UPDATE dispute
    SET status = v_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE dispute_id = p_dispute_id;

    INSERT INTO dispute_event(dispute_id, event_type, actor)
    VALUES (p_dispute_id, v_new_status, p_actor);
END;
$$;


CREATE OR REPLACE PROCEDURE dispute_pkg.sp_issue_refund(
    p_dispute_id BIGINT,
    p_actor      VARCHAR
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_amount NUMERIC;
BEGIN
    -- Step 1: Validate & lock dispute row
    SELECT claim_amount
    INTO v_amount
    FROM dispute
    WHERE dispute_id = p_dispute_id
      AND status = 'APPROVED'
        FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Refund not allowed for this dispute';
    END IF;

    -- Step 1.1: Prevent duplicate refund
    IF EXISTS (
        SELECT 1 FROM refund WHERE dispute_id = p_dispute_id
    ) THEN
        RAISE EXCEPTION 'Refund already processed for this dispute';
    END IF;

    -- Step 2: Mark refund initiated
    UPDATE dispute
    SET status = 'REFUND_INITIATED',
        updated_at = CURRENT_TIMESTAMP
    WHERE dispute_id = p_dispute_id;

    INSERT INTO dispute_event(dispute_id, event_type, actor)
    VALUES (p_dispute_id, 'REFUND_INITIATED', p_actor);

    -- Step 3: Insert refund record
    INSERT INTO refund (
        dispute_id, refund_amount, refund_status, reference_no
    )
    VALUES (
               p_dispute_id,
               v_amount,
               'COMPLETED',
               gen_random_uuid()::TEXT
           );

    -- Step 4: Mark refund completed
    UPDATE dispute
    SET status = 'REFUNDED',
        updated_at = CURRENT_TIMESTAMP
    WHERE dispute_id = p_dispute_id;

    INSERT INTO dispute_event(dispute_id, event_type, actor)
    VALUES (p_dispute_id, 'REFUNDED', p_actor);
END;
$$;


CREATE OR REPLACE FUNCTION dispute_pkg.trg_dispute_status_audit()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO dispute_status_history(
            dispute_id, old_status, new_status, changed_by
        )
        VALUES (
                   NEW.dispute_id,
                   OLD.status,
                   NEW.status,
                   'SYSTEM'
               );
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_dispute_status
    AFTER UPDATE ON dispute
    FOR EACH ROW
EXECUTE FUNCTION dispute_pkg.trg_dispute_status_audit();
