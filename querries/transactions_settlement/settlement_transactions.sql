-- Полная история операций по конкретному счету
-- С фильтрацией по дате, типу, сумме


SELECT *
FROM LegalEntity LE
JOIN SettlementAccount SA 
ON LE.id = SettlementAccount.settlement_id
JOIN SettlementPaymentTransactions SPT 
ON SA.id = SPT.account_id
JOIN TransactionType TT 
ON TT.id = SPT.currency_id
WHERE LE.name = 'Рога и копыта' AND amount > 10000 AND created_at > DATE '2023-08-12'


-- Операции с суммой выше определенного лимита
-- Для контроля и проверки


SELECT *
FROM LegalEntity LE
JOIN SettlementAccount SA 
ON LE.id = SettlementAccount.settlement_id
JOIN SettlementPaymentTransactions SPT 
ON SA.id = SPT.account_id
JOIN TransactionType TT 
ON TT.id = SPT.currency_id
WHERE SPT.primary_amount > 1000


-- Счета с частотой транзаций реже чем пол года

WITH A AS (SELECT 
    SA.id, 
    CASE   
        WHEN LAG(SA.created_at) OVER(
            PARTITION BY SA.id
            ORDER BY SA.created_at
        ) IS NULL 
        OR EXTRACT(EPOCH FROM (SA.created_at - LAG(SA.created_at) OVER(
            PARTITION BY SA.id
            ORDER BY SA.created_at
        ))::INTERVAL) < 15768000 
        THEN 1 ELSE 0 
    END as prev_bounded,
    CASE   
        WHEN LEAD(SA.created_at) OVER(
            PARTITION BY SA.id
            ORDER BY SA.created_at
        ) IS NULL 
        OR EXTRACT(EPOCH FROM (LEAD(SA.created_at - SA.created_at) OVER(
            PARTITION BY SA.id
            ORDER BY SA.created_at
        ))::INTERVAL) < 15768000 
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


WITH A AS (SELECT 
    *,
    CASE 
        WHEN TT.name = 'income' 
            THEN SPT.primary_amount - SPT.primary_amount * COALESCE(EPT.ratio, 0) - COALESCE(EPT.absolute, 0)
        WHEN TT.name = 'expense' 
            THEN 0 - SPT.primary_amount - SPT.primary_amount * COALESCE(EPT.ratio, 0) - COALESCE(EPT.absolute, 0)
    END as cash_flow,
FROM SettlementAccount SA 
JOIN SettlementPaymentTransactions SPT
ON SA.id = SPT.account_id
JOIN TransactionType TT 
ON TT.id = SPT.type_id
LEFT JOIN EntityPaymentFee EPT
ON EPT.id = SPT.fee_id
)

SELECT 
    -- допиши что надо заселектить



-- Топ-10 получателей
-- Анализ бизнес-связей

SELECT 
FROM LegalEntity LE 
JOIN SettlementAccount SA 
ON LE.id = SA.settlement_id

SettlementPaymentTransactions 


-- Топ-10 отправителей
-- Анализ бизнес-связей




-- Аномалии: круглые суммы, нестандартное время, новые контрагенты
-- AML (Anti-Money Laundering) проверки




-- Операции ночью/в выходные
-- Для проверки легитимности