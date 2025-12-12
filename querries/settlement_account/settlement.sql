-- all settlement accounts of a legal entity

SELECT LE.*,
    MIN(SA.balance) OVER(PARTITION BY LE.id) AS minimal_balance,
    MAX(SA.balance) OVER(PARTITION BY LE.id) AS maximal_balance,
    AVG(SA.balance) OVER(PARTITION BY LE.id) AS mean_balance
FROM LegalEntity LE
JOIN SettlementAccount SA ON LE.id = SA.settlement_id;

-- credit accounts with low or negative balance with last transaction older than 1 month

WITH A AS (
    SELECT *, 
    MAX(CA.created_at) OVER(
        PARTITION BY CA.id 
        ORDER BY CA.created_at
    ) as last_payment,
    FROM LegalEntity LE
    JOIN CreditAccount CA 
    ON LE.id = CA.settlement_id
    JOIN CreditTransactions CT 
    ON CA.id = CT.account_id
    JOIN TransactionType TT 
    ON CT.type_id = TT.id
    WHERE TT.name = 'IN'
)

SELECT 
    LE.id, 
    LE.name, 
    last_payment, 
    CA.balance 
FROM A 
WHERE 
    NOW() - last_payment > INTERVAL '30 days'
    AND CA.balance < 0
ORDER BY LE.id ASC, CA.balance DESC;


-- shows not closed legal entity accounts 

SELECT LE.id, LE.name, SA.*
FROM LegalEntity LE
JOIN SettlementAccount SE 
ON LE.id = SE.settlement_id
WHERE SE.status != 'closed';


-- shows foreign currency accounts in one particular currency

SELECT LE.id, LE.name, FCA.*, SC.ticker, SC.country
FROM LegalEntity LE
JOIN ForeignCurrencyAccount FCA
ON LE.id = FCA.settlement_id
JOIN SettlementCurrency SC 
ON SC.id = FCA.currency_id
WHERE SC.ticker = 'USD';


-- gives statistics on account statuses

SELECT LE.id, LE.name, COUNT(*) as account_statistics
FROM LegalEntity LE
JOIN SettlementAccount SE 
ON LE.id = SE.settlement_id
GROUP BY LE.id, LE.name, SE.id, SE.status










