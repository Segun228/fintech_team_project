-- USER ACCOUNTS


WITH UserAccounts AS (
    SELECT 
        I.id as user_id,
        I.first_name,
        I.surname,
        MA.id as main_account_id,
        MA.agreement_num,
        MA.created_at as account_created
    FROM Individual I
    JOIN MainAccount MA ON I.id = MA.user_id
)
SELECT 
    UA.*,
    DA.id as debit_card_id,
    DA.card_num,
    DA.card_validity,
    DA.amount as card_balance,
    DA.currency_id
FROM UserAccounts UA
JOIN DebutAccount DA ON UA.main_account_id = DA.main_account_num
ORDER BY UA.user_id, DA.created_at;

-- Accounts with no debud accounts

SELECT 
    I.id as user_id,
    I.first_name,
    I.surname,
    I.phone_num,
    MA.id as main_account_id,
    MA.agreement_num,
    MA.created_at as account_created
FROM Individual I
JOIN MainAccount MA ON I.id = MA.user_id
LEFT JOIN DebutAccount DA ON MA.id = DA.main_account_num  -- исправлено поле
WHERE DA.id IS NULL
ORDER BY MA.created_at DESC;


-- quantile tranformation

WITH A AS (
    SELECT *, NTILE(4) OVER(ORDER BY created_at) as quartile
    FROM MainAccount 
)

WITH B AS (
    SELECT 
        COUNT(*),
        FIRST_VALUE() OVER(
            PARTITION BY quartile
            ORDER BY created_at
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as quartile_start,
        LAST_VALUE() OVER(
            PARTITION BY quartile
            ORDER BY created_at
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as quartile_end,
        ROW_NUMBER() OVER(
            PARTITION BY quartile
            ORDER BY created_at
        ) as window_number,
        COUNT(*) OVER(
            PARTITION BY quartile
        ) as window_length,
    FROM DebutAccount
)

SELECT *, window_number / widnow_length * 100 AS percentile
FROM B
ORDER BY quartile, window_number


-- Time from client registration to first account opening

SELECT 
    I.id,
    I.first_name,
    I.surname,
    I.created_at as client_registered,
    MIN(MA.created_at) as first_account_opened,
    EXTRACT(DAY FROM MIN(MA.created_at) - I.created_at) as days_to_first_account,
    CASE 
        WHEN EXTRACT(DAY FROM MIN(MA.created_at) - I.created_at) = 0 THEN 'Same day'
        WHEN EXTRACT(DAY FROM MIN(MA.created_at) - I.created_at) <= 7 THEN 'Within week'
        WHEN EXTRACT(DAY FROM MIN(MA.created_at) - I.created_at) <= 30 THEN 'Within month'
        ELSE 'Over month'
    END as activation_speed
FROM Individual I
JOIN MainAccount MA ON I.id = MA.user_id
GROUP BY I.id, I.first_name, I.surname, I.created_at
ORDER BY days_to_first_account DESC;


-- When are accounts most frequently opened

SELECT 
    EXTRACT(HOUR FROM created_at) as opening_hour,
    COUNT(*) as accounts_opened,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage,
    CASE 
        WHEN COUNT(*) = MAX(COUNT(*)) OVER() THEN 'PEAK'
        WHEN COUNT(*) >= 0.8 * MAX(COUNT(*)) OVER() THEN 'HIGH'
        ELSE 'NORMAL'
    END as traffic_level
FROM MainAccount
GROUP BY EXTRACT(HOUR FROM created_at)
ORDER BY opening_hour;


-- accounts opened while month + year

SELECT COUNT(*), DATE_TRUNC('month', MA.created_at) AS timestamp
FROM Individual I 
JOIN MainAccount MA 
ON I.id = MA.account_id
GROUP BY timestamp

