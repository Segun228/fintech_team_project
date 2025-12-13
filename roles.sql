-- Для менеджеров - данные клиентов (нет паролей и паспортных данных)
CREATE VIEW v_safe_individuals AS
SELECT id, first_name, surname, patronymic, phone_num, created_at, 'resident' as status_type
FROM Individual;

-- Для аналитиков - только статистика по счетам (без привязки к личности)
CREATE VIEW v_account_statistics AS
SELECT 
    currency_id, 
    COUNT(*) as total_accounts, 
    SUM(amount) as total_balance 
FROM DebutAccount 
GROUP BY currency_id;

-- Роль 1 - менеджер
-- Права: чтение данных клиентов, регистрация новых, открытие счетов, смена фамилии/телефона
CREATE ROLE manager WITH LOGIN PASSWORD 'manager123';
GRANT SELECT ON v_safe_individuals TO manager;
GRANT INSERT ON Individual, LegalEntity TO manager;
GRANT INSERT ON DebutAccount, SavingsAccount TO manager;
GRANT UPDATE (phone_num, surname) ON Individual TO manager;

-- Роль 2 - бэкенд
-- Права: полный технический доступ (CRUD) ко всем таблицам, запуск функций и использование счетчико
CREATE ROLE backend WITH LOGIN PASSWORD 'backend123';
GRANT INSERT, UPDATE, SELECT ON ALL TABLES IN SCHEMA public TO backend;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO backend;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO backend;

-- Роль 3 - аналитик
-- Права: только чтение
CREATE ROLE analyst WITH LOGIN PASSWORD 'analyst123';
GRANT SELECT ON v_account_statistics TO analyst;
GRANT SELECT ON ExchangeRate, StockPrices, Stocks TO analyst;

-- Роль 4 - администратор инвестиций
-- Права: полный контроль над инвестициями (акции, типы акций, брокерские счета), но нет доступа к обычным счетам
CREATE ROLE stock_admin WITH LOGIN PASSWORD 'stock_admin123';
GRANT ALL PRIVILEGES ON Stocks, StockTypes, StockPrices TO stock_admin;
GRANT ALL PRIVILEGES ON BrokerageAccount, UserStock TO stock_admin;
GRANT INSERT ON StockTransactionTypes TO stock_admin;
