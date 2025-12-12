-- Полная история операций по конкретному счету
-- С фильтрацией по дате, типу, сумме


SELECT LE.name as company_name,
    SA.id as account_id,
    SPT.*,
    TT.name as transaction_type
FROM LegalEntity LE
JOIN SettlementAccount SA ON LE.id = SA.settlement_id
JOIN SettlementPaymentTransactions SPT ON SA.id = SPT.account_id
JOIN TransactionType TT ON TT.id = SPT.type_id  -- исправлено!
WHERE LE.name = 'Рога и копыта' 
AND SPT.primary_amount > 10000 
AND SPT.created_at > DATE '2023-08-12';

-- Операции с суммой выше определенного лимита
-- Для контроля и проверки


SELECT LE.name as company_name,
    SA.id as account_id,
    SPT.primary_amount,
    SPT.created_at,
    TT.name as transaction_type
FROM LegalEntity LE
JOIN SettlementAccount SA ON LE.id = SA.settlement_id
JOIN SettlementPaymentTransactions SPT ON SA.id = SPT.account_id
JOIN TransactionType TT ON TT.id = SPT.type_id
WHERE SPT.primary_amount > 1000
ORDER BY SPT.primary_amount DESC;


-- Счета с частотой транзаций реже чем пол года

WITH A AS (SELECT 
    SA.id, 
    CASE   
        WHEN LAG(SA.created_at) OVER(
            PARTITION BY SA.id
            ORDER BY SA.created_at
        ) IS NULL 
        OR EXTRACT(EPOCH FROM INTERVAL(SA.created_at - LAG(SA.created_at) OVER(
            PARTITION BY SA.id
            ORDER BY SA.created_at
        ))) < 15768000 
        THEN 1 ELSE 0 
    END as prev_bounded,
    CASE   
        WHEN LEAD(SA.created_at) OVER(
            PARTITION BY SA.id
            ORDER BY SA.created_at
        ) IS NULL 
        OR EXTRACT(EPOCH FROM INTERVAL(LEAD(SA.created_at - SA.created_at) OVER(
            PARTITION BY SA.id
            ORDER BY SA.created_at
        ))) < 15768000 
        THEN 1 ELSE 0 
    END as next_bounded
FROM SettlementAccount SA 
JOIN SettlementPaymentTransactions SPT
ON SA.id = SPT.account_id
)

SELECT * 
FROM A 
WHERE prev_bounded != 1 OR next_bounded != 1;




-- Cash flow: разница между поступлениями и выплатами
-- Оборот по счету


WITH A AS (
    SELECT 
        SA.id as account_id,
        LE.name as company_name,
        SPT.created_at,
        SPT.primary_amount,
        TT.name as transaction_type,
        CASE 
            WHEN TT.name = 'income' 
                THEN SPT.primary_amount - SPT.primary_amount * COALESCE(EPT.ratio, 0) - COALESCE(EPT.absolute, 0)
            WHEN TT.name = 'expense' 
                THEN 0 - SPT.primary_amount - SPT.primary_amount * COALESCE(EPT.ratio, 0) - COALESCE(EPT.absolute, 0)
        END as cash_flow
    FROM SettlementAccount SA 
    JOIN SettlementPaymentTransactions SPT ON SA.id = SPT.account_id
    JOIN LegalEntity LE ON SA.settlement_id = LE.id
    JOIN TransactionType TT ON TT.id = SPT.type_id
    LEFT JOIN EntityPaymentFee EPT ON EPT.id = SPT.fee_id
    WHERE SPT.created_at >= CURRENT_DATE - INTERVAL '30 days'
)

SELECT 
    company_name,
    account_id,
    COUNT(*) as transaction_count,
    SUM(cash_flow) as total_cash_flow,
    AVG(cash_flow) as avg_cash_flow,
    MIN(cash_flow) as min_cash_flow,
    MAX(cash_flow) as max_cash_flow
FROM A
GROUP BY company_name, account_id
ORDER BY total_cash_flow DESC;




-- Аномалии: круглые суммы, нестандартное время, новые контрагенты
-- AML (Anti-Money Laundering) проверки

-- круглые суммы
SELECT SPT.*, LE.name as company
FROM SettlementPaymentTransactions SPT
JOIN SettlementAccount SA ON SPT.account_id = SA.id
JOIN LegalEntity LE ON SA.settlement_id = LE.id
WHERE SPT.primary_amount % 100000 = 0
ORDER BY SPT.created_at DESC;

-- Все платежи ночью
SELECT SPT.*, LE.name as company
FROM SettlementPaymentTransactions SPT
JOIN SettlementAccount SA ON SPT.account_id = SA.id
JOIN LegalEntity LE ON SA.settlement_id = LE.id
WHERE EXTRACT(HOUR FROM SPT.created_at) < 6 
ORDER BY SPT.created_at DESC;
