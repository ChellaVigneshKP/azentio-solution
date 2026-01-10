INSERT INTO customer (cust_id, name, kyc_status)
VALUES (1, 'Ravi Kumar', 'FULL'),
       (2, 'Anita Sharma', 'PARTIAL'),
       (3, 'John Doe', 'NONE');

INSERT INTO account (acct_id, cust_id, status, balance)
VALUES (1, 1, 'ACTIVE', 50000),
       (2, 2, 'ACTIVE', 20000),
       (3, 3, 'ACTIVE', 10000);


INSERT INTO txn (txn_id, acct_id, amount, txn_ts, merchant, status)
VALUES (1, 1, 1200, CURRENT_TIMESTAMP - INTERVAL '5 days', 'Amazon', 'SETTLED'),
       (2, 1, 6000, CURRENT_TIMESTAMP - INTERVAL '3 days', 'Flipkart', 'SETTLED'),
       (3, 2, 1500, CURRENT_TIMESTAMP - INTERVAL '10 days', 'Swiggy', 'SETTLED'),
       (4, 3, 900, CURRENT_TIMESTAMP - INTERVAL '2 days', 'Zomato', 'SETTLED');


INSERT INTO txn (txn_id, acct_id, amount, txn_ts, merchant, status)
VALUES (5, 1, 800, CURRENT_TIMESTAMP - INTERVAL '45 days', 'Netflix', 'SETTLED'),
       (6, 2, 400, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Uber', 'REVERSED'),
       (7, 3, 300, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Ola', 'CHARGEBACK_DONE');


CALL dispute_pkg.sp_create_dispute(
        1, 1, 'DUPLICATE_CHARGE', 1200, 'CUSTOMER'
     );

CALL dispute_pkg.sp_create_dispute(
        2, 1, 'DUPLICATE_CHARGE', 6000, 'CUSTOMER'
     );

CALL dispute_pkg.sp_create_dispute(
        3, 2, 'SERVICE_NOT_DELIVERED', 1500, 'CUSTOMER'
     );

CALL dispute_pkg.sp_create_dispute(
        4, 3, 'FRAUD_SUSPECTED', 900, 'CUSTOMER'
     );


CALL dispute_pkg.sp_decide_dispute(1, 'SYSTEM');
CALL dispute_pkg.sp_decide_dispute(2, 'SYSTEM');
CALL dispute_pkg.sp_decide_dispute(3, 'SYSTEM');
CALL dispute_pkg.sp_decide_dispute(4, 'SYSTEM');
