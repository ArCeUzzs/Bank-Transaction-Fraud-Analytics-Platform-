use bank;
CREATE TABLE IF NOT EXISTS transactions ( step INT, type VARCHAR(20), amount DECIMAL(15,2),
 nameOrig VARCHAR(20), oldbalanceOrg DECIMAL(15,2), newbalanceOrig DECIMAL(15,2),
 nameDest VARCHAR(20), oldbalanceDest DECIMAL(15,2), newbalanceDest DECIMAL(15,2),
 isFraud TINYINT, isFlaggedFraud TINYINT );
CREATE INDEX idx_fraud_transfer 
ON transactions (isFraud, type, step);

CREATE INDEX idx_nameorig_step 
ON transactions (nameOrig, step);

CREATE INDEX idx_nameorig_step_fraud
ON transactions (nameOrig, step, isFraud);


CREATE INDEX idx_namedest_step 
ON transactions (nameDest, step);

CREATE INDEX idx_amount 
ON transactions (amount);

SELECT * FROM transactions;

CREATE TABLE IF NOT EXISTS fraud_chain (
    initial_account VARCHAR(50),
    next_account VARCHAR(50),
    step INT,
    chain_depth INT,
    PRIMARY KEY (initial_account, next_account, step),
    INDEX idx_fc_next (next_account, step),
    INDEX idx_fc_initial (initial_account, chain_depth)
);

CREATE TABLE IF NOT EXISTS rolling_fraud_score (
    account VARCHAR(20) PRIMARY KEY,
    rolling_risk INT NOT NULL,
    last_step INT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS fraud_risk_summary (
    account VARCHAR(20) PRIMARY KEY,
    raw_score INT NOT NULL,
    normalized_fraud_score DECIMAL(5,2),
    risk_level VARCHAR(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);




-- 1. Detecting Recursive Fraudulent Transactions
-- FOR FIRST UPDATE RUN ONCE
INSERT IGNORE INTO fraud_chain
WITH RECURSIVE fc AS (

    -- Anchor: first fraudulent transfers
    SELECT 
        nameOrig AS initial_account,
        nameDest AS next_account,
        step,
        1 AS chain_depth
    FROM transactions
    WHERE isFraud = 1
      AND type = 'TRANSFER'

    UNION ALL

    -- Recursive: follow money trail
    SELECT 
        fc.initial_account,
        t.nameDest,
        t.step,
        fc.chain_depth + 1
    FROM fc
    JOIN transactions t
      ON fc.next_account = t.nameOrig
     AND fc.step < t.step
    WHERE t.isFraud = 1
      AND t.type = 'TRANSFER'
      AND fc.chain_depth < 10   -- safety limit
)
SELECT * FROM fc;
SELECT * FROM fraud_chain;

-- FOR NEXT UPDATES CAN RUN WHENEVER WE WANT TO UPDATE THE DATA WILL NOT REREAD 

INSERT IGNORE INTO fraud_chain
WITH RECURSIVE fc AS (

    -- Anchor: ONLY new fraudulent transfers
    SELECT 
        nameOrig AS initial_account,
        nameDest AS next_account,
        step,
        1 AS chain_depth
    FROM transactions
    WHERE isFraud = 1
      AND type = 'TRANSFER'
      AND step > (SELECT COALESCE(MAX(step), 0) FROM fraud_chain)

    UNION ALL

    -- Recursive: extend chains forward
    SELECT 
        fc.initial_account,
        t.nameDest,
        t.step,
        fc.chain_depth + 1
    FROM fc
    JOIN transactions t
      ON fc.next_account = t.nameOrig
     AND fc.step < t.step
    WHERE t.isFraud = 1
      AND t.type = 'TRANSFER'
      AND fc.chain_depth < 10
)
SELECT * FROM fc;
SELECT * FROM fraud_chain;


-- ROLLING FRAUD DETECTION ( BY PAST 5 TRANSACTION)


INSERT INTO rolling_fraud_score (account, rolling_risk, last_step)
SELECT
    account,
    MAX(fraud_rolling) * 5 AS rolling_risk,
    MAX(step) AS last_step
FROM (
    SELECT
        t.nameOrig AS account,
        t.step,
        SUM(t.isFraud) OVER (
            PARTITION BY t.nameOrig
            ORDER BY t.step
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ) AS fraud_rolling
    FROM transactions t
    LEFT JOIN rolling_fraud_score r
        ON t.nameOrig = r.account
    WHERE r.last_step IS NULL
       OR t.step > r.last_step - 4
) w
GROUP BY account
ON DUPLICATE KEY UPDATE
    rolling_risk = GREATEST(rolling_risk, VALUES(rolling_risk)),
    last_step = VALUES(last_step);


-- Fraud Risk Scoring Model

CREATE TEMPORARY TABLE tmp_fraud_risk AS
WITH
chain_score AS (
    SELECT initial_account AS account,
           MAX(chain_depth) * 10 AS chain_risk
    FROM fraud_chain
    GROUP BY initial_account
),
large_transfer_score AS (
    SELECT nameOrig AS account,
           COUNT(*) * 5 AS large_risk
    FROM transactions
    WHERE type = 'TRANSFER' AND amount > 500000
    GROUP BY nameOrig
),
balance_mismatch_score AS (
    SELECT nameOrig AS account,
           COUNT(*) * 5 AS balance_risk
    FROM transactions
    WHERE ABS(newbalanceDest - (oldbalanceDest + amount)) > 0.01
    GROUP BY nameOrig
),
raw_risk AS (
    SELECT r.account,
           COALESCE(c.chain_risk, 0)
         + r.rolling_risk
         + COALESCE(l.large_risk, 0)
         + COALESCE(b.balance_risk, 0) AS raw_score
    FROM rolling_fraud_score r
    LEFT JOIN chain_score c ON r.account = c.account
    LEFT JOIN large_transfer_score l ON r.account = l.account
    LEFT JOIN balance_mismatch_score b ON r.account = b.account
),
max_score AS (
    SELECT MAX(raw_score) AS max_raw_score
    FROM raw_risk
)
SELECT
    rr.account,
    rr.raw_score,
    ROUND((rr.raw_score / NULLIF(ms.max_raw_score, 0)) * 100, 2) AS normalized_fraud_score,
    CASE
        WHEN (rr.raw_score / NULLIF(ms.max_raw_score, 0)) * 100 >= 75 THEN 'High Risk'
        WHEN (rr.raw_score / NULLIF(ms.max_raw_score, 0)) * 100 >= 40 THEN 'Medium Risk'
        WHEN (rr.raw_score / NULLIF(ms.max_raw_score, 0)) * 100 > 0 THEN 'Low Risk'
        ELSE 'No Risk'
    END AS risk_level
FROM raw_risk rr
CROSS JOIN max_score ms;

-- Step 2: Insert from temporary table with ON DUPLICATE KEY UPDATE
INSERT INTO fraud_risk_summary (account, raw_score, normalized_fraud_score, risk_level)
SELECT account, raw_score, normalized_fraud_score, risk_level
FROM tmp_fraud_risk
ON DUPLICATE KEY UPDATE
    raw_score = VALUES(raw_score),
    normalized_fraud_score = VALUES(normalized_fraud_score),
    risk_level = VALUES(risk_level);

-- Step 3: Drop temporary table 
DROP TEMPORARY TABLE IF EXISTS tmp_fraud_risk;

SELECT *
FROM fraud_risk_summary
ORDER BY normalized_fraud_score DESC
LIMIT 20;






