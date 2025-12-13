-- Получить все депозитные счета конкретного клиента с информацией о валюте и данных владельца
SELECT SA.*, UC.ticker as currency, I.first_name, I.surname
FROM SavingsAccount SA
JOIN UserCurrency UC ON SA.currency_id = UC.id
JOIN MainAccount MA ON SA.main_account_num = MA.id
JOIN Individual I ON MA.user_id = I.id
WHERE I.id = 123;

-- Найти депозиты с процентной ставкой выше 8%, отсортированные по убыванию ставки
SELECT SA.*, I.first_name, I.surname, UC.ticker as currency
FROM SavingsAccount SA
JOIN MainAccount MA ON SA.main_account_num = MA.id
JOIN Individual I ON MA.user_id = I.id
JOIN UserCurrency UC ON SA.currency_id = UC.id
WHERE SA.bet > 8
ORDER BY SA.bet DESC;

-- Найти депозиты, срок действия которых истекает в ближайшие 30 дней
SELECT SA.*, I.first_name, I.surname, 
       SA.created_at + INTERVAL '1 year' as end_date,
       (SA.created_at + INTERVAL '1 year') - CURRENT_DATE as days_left
FROM SavingsAccount SA
JOIN MainAccount MA ON SA.main_account_num = MA.id
JOIN Individual I ON MA.user_id = I.id
WHERE (SA.created_at + INTERVAL '1 year') BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';

-- Получить статистику по депозитам в разрезе валют
SELECT UC.ticker as currency, UC.country,
       COUNT(*) as deposit_count,
       SUM(SA.amount) as total_amount,
       AVG(SA.bet) as avg_rate
FROM SavingsAccount SA
JOIN UserCurrency UC ON SA.currency_id = UC.id
GROUP BY UC.ticker, UC.country
ORDER BY total_amount DESC;

-- Найти 10 самых крупных депозитов по сумме
SELECT SA.*, I.first_name, I.surname, UC.ticker as currency
FROM SavingsAccount SA
JOIN MainAccount MA ON SA.main_account_num = MA.id
JOIN Individual I ON MA.user_id = I.id
JOIN UserCurrency UC ON SA.currency_id = UC.id
ORDER BY SA.amount DESC
LIMIT 10;

-- Найти депозиты, срок действия которых уже истек
SELECT SA.*, I.first_name, I.surname,
       SA.created_at + INTERVAL '1 year' as end_date,
       CURRENT_DATE - (SA.created_at + INTERVAL '1 year') as days_overdue
FROM SavingsAccount SA
JOIN MainAccount MA ON SA.main_account_num = MA.id
JOIN Individual I ON MA.user_id = I.id
WHERE SA.created_at + INTERVAL '1 year' < CURRENT_DATE;

-- Найти депозиты с включенной капитализацией процентов
SELECT SA.*, I.first_name, I.surname
FROM SavingsAccount SA
JOIN MainAccount MA ON SA.main_account_num = MA.id
JOIN Individual I ON MA.user_id = I.id
WHERE SA.capitalization = true;

-- Получить статистику открытия депозитов по месяцам
SELECT 
    EXTRACT(YEAR FROM SA.created_at) as year,
    EXTRACT(MONTH FROM SA.created_at) as month,
    COUNT(*) as deposits_opened,
    SUM(SA.amount) as total_amount,
    AVG(SA.bet) as avg_rate
FROM SavingsAccount SA
GROUP BY EXTRACT(YEAR FROM SA.created_at), EXTRACT(MONTH FROM SA.created_at)
ORDER BY year DESC, month DESC;

-- Найти депозиты, на которые были пополнения после открытия
SELECT DISTINCT SA.*, I.first_name, I.surname
FROM SavingsAccount SA
JOIN MainAccount MA ON SA.main_account_num = MA.id
JOIN Individual I ON MA.user_id = I.id
WHERE EXISTS (
    SELECT 1 FROM Transactions T 
    WHERE T.recipient_acc = MA.id 
    AND T.amount > 0
    AND T.date_transaction > SA.created_at
);

-- Получить статистику по процентным ставкам в разрезе валют
SELECT UC.ticker as currency,
       COUNT(*) as deposit_count,
       MIN(SA.bet) as min_rate,
       MAX(SA.bet) as max_rate,
       AVG(SA.bet) as avg_rate,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY SA.bet) as median_rate
FROM SavingsAccount SA
JOIN UserCurrency UC ON SA.currency_id = UC.id
GROUP BY UC.ticker
ORDER BY avg_rate DESC;