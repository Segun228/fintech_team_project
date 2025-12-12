-- Все комиссии сгруппированные по типам операций
-- Показывает: тип операции, вид комиссии (процентная/абсолютная), размер

WITH A AS (
    SELECT (EXTRACT(EPOCH FROM (MAX(created_at) - MIN(created_at))) / 2592000)::INT AS month_length
    FROM UserPaymentFee
),

B AS (
    SELECT UPF.*,
            NTILE(A.month_length) OVER(
                PARTITION BY trans_type
                ORDER BY created_at
            ) AS count_period
    FROM UserPaymentFee UPF
    CROSS JOIN A
)

SELECT trans_type,
    AVG(ratio) as mean_ratio_fee,
    AVG(absolute) as mean_absolute_fee,
    MAX(ratio) as max_ratio_fee,
    MAX(absolute) as max_absolute_fee,
    MIN(ratio) as min_ratio_fee,
    MIN(absolute) as min_absolute_fee
FROM B
GROUP BY trans_type, count_period
ORDER BY trans_type, count_period;


-- 6 по величине комиссия среди всех транзакций


WITH A AS (SELECT 
    T.amount AS transaction_amount,
    T.amount * UPF.ratio + UPF.absolute AS transaction_total_fee,
FROM Transactions T 
JOIN UserPaymentFee UPF
ON T.comission_id = UPF.id
),

B AS (
    SELECT *,
    ROW_NUMBER() OVER(
        ORDER BY transaction_total_fee DESC
    ) AS num
)

SELECT *
FROM B 
WHERE num = 6;


-- История изменения тарифов для каждого типа операций
-- Когда и как менялись комиссии

WITH A AS (
    SELECT EXTRACT(DAY FROM INTERVAL (MAX(created_at) - MIN(created_at))) AS month_length
    FROM UserPaymentFee
    LIMIT 1
),

B AS (
    SELECT *,
    NTILE(month_length) OVER(
        PARTITION BY trans_type
        ORDER BY created_at
    ) AS count_period
    FROM A
)

SELECT 
    trans_type, 
    AVG(ratio) mean_ratio_fee, 
    AVG(absolute) mean_absolute_fee, 
    FROM B
    GROUP BY trans_type, 
    ORDER BY
        trans_type,
        count_period;


-- Ожидаемый доход на основе истории операций
-- Сезонность комиссионных сборов


WITH fee_calculations AS (
    SELECT 
        T.amount AS transaction_amount,
        T.amount * UPF.ratio + UPF.absolute AS transaction_total_fee,
        T.date_transaction,
        DATE_TRUNC('month', T.date_transaction) as transaction_month,
        EXTRACT(DOW FROM T.date_transaction) as day_of_week,
        EXTRACT(HOUR FROM T.date_transaction) as hour_of_day
    FROM Transactions T 
    JOIN UserPaymentFee UPF ON T.comission_id = UPF.id
),

monthly_stats AS (
    SELECT 
        transaction_month,
        COUNT(*) as transaction_count,
        SUM(transaction_total_fee) as total_fee_income,
        AVG(transaction_total_fee) as avg_fee_per_transaction,
        AVG(SUM(transaction_total_fee)) OVER(
            ORDER BY transaction_month 
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) as forecast_next_month
    FROM fee_calculations
    GROUP BY transaction_month
),

seasonality AS (
    SELECT 
        day_of_week,
        hour_of_day,
        AVG(transaction_total_fee) as avg_fee,
        COUNT(*) as transaction_count,
        SUM(transaction_total_fee) as total_fee
    FROM fee_calculations
    GROUP BY day_of_week, hour_of_day
)

SELECT 
    'month_report' as report_type,
    transaction_month,
    transaction_count,
    total_fee_income,
    avg_fee_per_transaction,
    forecast_next_month
FROM monthly_stats

UNION ALL

SELECT 
    'seasonality' as report_type,
    NULL as transaction_month,
    transaction_count,
    total_fee,
    avg_fee,
    NULL as forecast_next_month
FROM seasonality

ORDER BY report_type, 
    CASE WHEN report_type = 'month_report' THEN transaction_month END,
    CASE WHEN report_type = 'seasonality' THEN day_of_week END,
    CASE WHEN report_type = 'seasonality' THEN hour_of_day END;
