-- search by fio


SELECT * 
FROM Individual
WHERE 
    first_name = 'Иван' AND
    surname = 'Иванов' AND
    (patronymic = 'Иванович' OR patronymic IS NULL);


SELECT * 
FROM Individual
WHERE 
    first_name ILIKE 'Иван%' AND
    surname ILIKE 'Иванов%' AND
    (patronymic ILIKE 'Иванович%' OR patronymic IS NULL);

-- new clients by the last year

SELECT 
    DATE_TRUNC('month', created_at) as registration_month,
    COUNT(*) as new_clients_count,
    first_name, surname
FROM Individual
WHERE created_at >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY registration_month DESC;


-- clients without available account

SELECT DISTINCT * 
FROM Individual I
LEFT JOIN MainAccount MA
ON I.id = MA.user_id
WHERE user_id IS NULL


-- clients with repeating phone numbers

WITH A AS (
    SELECT *, COUNT() OVER(PARTITION BY phoneNum) AS dupl
    FROM Individual
)

SELECT * 
FROM A 
WHERE dupl >= 2
ORDER BY phoneNum, created_at


-- statistics over age of the accounts

WITH account_ages AS (
    SELECT 
        id,
        first_name,
        surname,
        created_at,
        EXTRACT(DAY FROM CURRENT_DATE - created_at) as account_age_days,
        NTILE(4) OVER (ORDER BY created_at) as quartile  -- 4 квартиля по дате создания
    FROM Individual
)
SELECT 
    quartile,
    MIN(account_age_days) as min_age_days,
    MAX(account_age_days) as max_age_days,
    AVG(account_age_days) as avg_age_days,
    COUNT(*) as clients_count
FROM account_ages
GROUP BY quartile
ORDER BY quartile;


-- customers with missing parameters

SELECT *
FROM Individual
WHERE 
    INN IS NULL OR 
    passport_series IS NULL OR
    passport_nums IS NULL


WITH client_products AS (
    SELECT 
        I.id as client_id,
        I.first_name,
        I.surname,
        COUNT(DISTINCT),
        COUNT(DISTINCT MA.id) as main_accounts,
        COUNT(DISTINCT BA.id) as brokerage_accounts,
        COUNT(DISTINCT DA.id) as debit_cards,
        COUNT(DISTINCT LA.id) as loan_cards,
        COUNT(DISTINCT SA.id) as savings_accounts
    FROM Individual I
    LEFT JOIN MainAccount MA ON I.id = MA.user_id
    LEFT JOIN BrokerageAccount BA ON MA.id = BA.main_account_num
    LEFT JOIN DebutAccount DA ON MA.id = DA.main_account_num
    LEFT JOIN LoanAccount LA ON MA.id = LA.main_account_num
    LEFT JOIN SavingsAccount SA ON MA.id = SA.main_account_num
    GROUP BY I.id, I.first_name, I.surname
)
SELECT 
    *,
    main_accounts + brokerage_accounts + debit_cards + 
    loan_cards + savings_accounts as total_products
FROM client_products
ORDER BY total_products DESC
LIMIT 10;







