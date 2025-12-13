-- Актуальные цены на сегодня с названиями и типами

WITH A AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY stock_id ORDER BY updated_at DESC) AS current_position,  -- добавлен DESC
        COUNT(*) OVER(PARTITION BY stock_id) as group_size
    FROM StockPrices
)
SELECT A.*, S.ticker, ST.type_name  
FROM A 
JOIN Stocks S ON S.id = A.stock_id
JOIN StockTypes ST ON ST.id = S.stock_type 
WHERE current_position = 1; 



-- График изменения цены за период по тикеру


WITH A AS (
    SELECT SP.*, S.ticker, S.stock_type
    FROM StockPrices SP
    JOIN Stocks S ON S.id = SP.stock_id
    WHERE S.ticker = 'EQMX'
)
SELECT A.*, 
        ST.type_name,
        AVG(price) OVER(
            ORDER BY A.updated_at
            ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
        ) as moving_avg
FROM A 
JOIN StockTypes ST ON ST.id = A.stock_type
ORDER BY A.updated_at;

-- Топ-10 по текущей цене

WITH A AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY stock_id ORDER BY price DESC) AS current_position,
        COUNT(*) OVER(PARTITION BY stock_id) as window_size
    FROM Stocks S 
    JOIN StockPrices SP 
    ON S.id = SP.stock_id 
)

SELECT *
FROM (
    SELECT * 
    FROM A
    WHERE current_position = window_size
)
ORDER BY price
LIMIT 10;


-- Процент изменения цены за сегодня


WITH A AS (SELECT *
FROM (
    SELECT * 
    FROM (    
        SELECT *,
            ROW_NUMBER() OVER(PARTITION BY stock_id ORDER BY price DESC) AS current_position,
            COUNT(*) OVER() as window_size,
            LAG(price) OVER(PARTITION BY SP.id ORDER BY updated_at) as prev_price
        FROM Stocks S 
        JOIN StockPrices SP 
        ON S.id = SP.stock_id 
    )
    WHERE current_position = window_size
))

SELECT *,
CASE 
    WHEN prev_price IS NULL OR prev_price = 0
        THEN 0
        ELSE 100*(price - prev_price)/prev_price 
    END AS change_ratio
FROM A;


-- Наибольшие потери за день


WITH A AS (SELECT *
FROM (
    SELECT * 
    FROM (    
        SELECT *,
            ROW_NUMBER() OVER(PARTITION BY stock_id ORDER BY price DESC) AS current_position,
            COUNT(*) OVER() as window_size,
            LAG(price) OVER(PARTITION BY SP.id ORDER BY updated_at) as prev_price
        FROM Stocks S 
        JOIN StockPrices SP 
        ON S.id = SP.stock_id 
    )
    WHERE current_position = window_size
)),

B AS (
    SELECT *,
    CASE 
        WHEN prev_price IS NULL OR prev_price = 0
            THEN 0
            ELSE 100*(price - prev_price)/prev_price 
        END AS change_ratio
    FROM A
)

SELECT *
FROM B
WHERE change_ratio < 0
ORDER BY change_ratio
LIMIT 5



-- Какие акции и сколько штук у клиента сейчас
SELECT US.brock_acc_num, S.ticker, COUNT(*) as quantity
FROM UserStock US
JOIN StockTransactions ST ON US.transact_id = ST.id
JOIN Stocks S ON ST.stock_id = S.id
JOIN StockTransactionTypes STT ON ST.operation_type_id = STT.id
WHERE US.brock_acc_num = 123 
    AND STT.operation_name IN ('buy', 'sell')
GROUP BY US.brock_acc_num, S.ticker;



-- Какие акции чаще всего покупают

SELECT S.id, S.ticker, COUNT(*) AS total_sold
FROM Stocks S
JOIN StockPrices SP 
ON SP.stock_id = S.id
JOIN StockTransactions ST
ON SP.id = ST.stock_price_id
JOIN StockTransactionTypes STT
ON STT.id = ST.operation_type_id
WHERE STT.operation_name = 'buy'
GROUP BY S.id, S.ticker
ORDER BY total_sold DESC
LIMIT 10

