-- 1. Создание ENUM типов
CREATE TYPE resident_status AS ENUM ('resident', 'non-resident');
CREATE TYPE ACCOUNT_STATUS AS ENUM ('active', 'frozen', 'closed');

-- 2. Создание справочных таблиц
CREATE TABLE IF NOT EXISTS Individual (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    patronymic VARCHAR(255),
    INN VARCHAR(12) UNIQUE,
    passport_series INT NOT NULL,
    passport_nums INT NOT NULL,
    phone_num VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (passport_series, passport_nums)
);

CREATE TABLE IF NOT EXISTS TransactionType (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name VARCHAR(200) NOT NULL 
);

CREATE TABLE IF NOT EXISTS SettlementCurrency (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ticker VARCHAR(50) NOT NULL UNIQUE,
    country VARCHAR(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS StockTypes (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) NOT NULL
);

-- 3. Создание базовых сущностей
CREATE TABLE IF NOT EXISTS LegalEntity (
    id SERIAL PRIMARY KEY,
    name VARCHAR(500) NOT NULL UNIQUE,
    INN VARCHAR(12) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    owner_id INT NOT NULL,    
    CONSTRAINT fk_owner_id
        FOREIGN KEY (owner_id) REFERENCES Individual(id)
        ON DELETE CASCADE
);

-- 4. Создание основных счетов
CREATE TABLE IF NOT EXISTS MainAccount (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    BIC VARCHAR(11) NOT NULL,
    agreement_num INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Individual(id)
);

CREATE TABLE IF NOT EXISTS Stocks (
    id SERIAL PRIMARY KEY,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stock_type INT NOT NULL,
    ticker VARCHAR(10) UNIQUE NOT NULL,
    FOREIGN KEY (stock_type) REFERENCES StockTypes(id)
);

CREATE TABLE IF NOT EXISTS StockPrices (
    id SERIAL PRIMARY KEY,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stock_id INT NOT NULL,
    price NUMERIC(20, 4) NOT NULL CHECK (price >= 0),
    FOREIGN KEY (stock_id) REFERENCES Stocks(id)
);

CREATE TABLE IF NOT EXISTS StockTransactionTypes (
    id SERIAL PRIMARY KEY,
    operation_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS UserCurrency (
    id SERIAL PRIMARY KEY,
    ticker VARCHAR(50) NOT NULL UNIQUE,
    country VARCHAR(50) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS EntityPaymentFee (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    settlement_id INT NOT NULL,    
    CONSTRAINT fk_settlement_id
        FOREIGN KEY (settlement_id) REFERENCES LegalEntity(id)
        ON DELETE RESTRICT
        ON UPDATE SET NULL,
    ratio DECIMAL(15, 5) NOT NULL DEFAULT 0,
    absolute DECIMAL(15,2) NOT NULL DEFAULT 0,
    type_id INT NOT NULL,    
    CONSTRAINT fk_type_id
        FOREIGN KEY (type_id ) REFERENCES TransactionType(id)
        ON DELETE CASCADE
);

-- 5. Создание специализированных счетов
CREATE TABLE IF NOT EXISTS DebutAccount (
    id SERIAL PRIMARY KEY,
    BIC VARCHAR(11) NOT NULL,
    agreement_num INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    main_account_num INT NOT NULL,
    currency_id INT NOT NULL,
    card_num VARCHAR(16) NOT NULL UNIQUE,
    card_validity INT NOT NULL,
    CVV INT NOT NULL,
    amount DECIMAL(15, 2) DEFAULT 0 CHECK (amount >= 0),
    FOREIGN KEY (main_account_num) REFERENCES MainAccount(id),
    FOREIGN KEY (currency_id) REFERENCES SettlementCurrency(id)
);

CREATE TABLE IF NOT EXISTS BrokerageAccount (
    id SERIAL PRIMARY KEY,
    BIC VARCHAR(11) NOT NULL,
    agreement_num INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    main_account_num INT NOT NULL,
    depository VARCHAR(100) NOT NULL,
    tax_resident_status resident_status NOT NULL,
    depot_account_num INT NOT NULL UNIQUE,
    FOREIGN KEY (main_account_num) REFERENCES MainAccount(id)
);

CREATE TABLE IF NOT EXISTS LoanAccount (
    id SERIAL PRIMARY KEY,
    BIC VARCHAR(11) NOT NULL,
    agreement_num INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    main_account_num INT NOT NULL,
    currency_id INT NOT NULL,
    card_num VARCHAR(16) NOT NULL UNIQUE,
    card_validity INT NOT NULL,
    CVV INT NOT NULL,
    bet DECIMAL(5, 2) NOT NULL CHECK (bet >= 0),
    repayment_period INT NOT NULL CHECK (repayment_period > 0),
    limit_amount DECIMAL(15, 2) NOT NULL CHECK (limit_amount > 0),
    FOREIGN KEY (main_account_num) REFERENCES MainAccount(id),
    FOREIGN KEY (currency_id) REFERENCES SettlementCurrency(id)
);

CREATE TABLE IF NOT EXISTS SavingsAccount (
    id SERIAL PRIMARY KEY,
    bic VARCHAR(11) UNIQUE NOT NULL,
    agreement_num INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    main_account_num INT NOT NULL,
    currency_id INT NOT NULL,
    bet DECIMAL(5, 2),
    amount DECIMAL(15, 2),
    FOREIGN KEY (currency_id) REFERENCES UserCurrency(id),
    FOREIGN KEY (main_account_num) REFERENCES MainAccount(id)
);

CREATE TABLE IF NOT EXISTS SettlementAccount (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    settlement_id INT NOT NULL,    
    CONSTRAINT fk_settlement_id
        FOREIGN KEY (settlement_id) REFERENCES LegalEntity(id)
        ON DELETE CASCADE,
    currency_id INT NOT NULL,    
    CONSTRAINT fk_currency_id
        FOREIGN KEY (currency_id) REFERENCES SettlementCurrency(id)
        ON DELETE RESTRICT,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    status ACCOUNT_STATUS DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS ForeignCurrencyAccount (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    settlement_id INT NOT NULL,    
    CONSTRAINT fk_settlement_id
        FOREIGN KEY (settlement_id) REFERENCES LegalEntity(id)
        ON DELETE CASCADE,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    status ACCOUNT_STATUS DEFAULT 'active',
    currency_id INT NOT NULL,    
    CONSTRAINT fk_currency_id
        FOREIGN KEY (currency_id) REFERENCES SettlementCurrency(id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS CreditAccount (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    settlement_id INT NOT NULL,    
    CONSTRAINT fk_settlement_id
        FOREIGN KEY (settlement_id) REFERENCES LegalEntity(id)
        ON DELETE CASCADE,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    status ACCOUNT_STATUS DEFAULT 'active',
    currency_id INT NOT NULL,    
    CONSTRAINT fk_currency_id
        FOREIGN KEY (currency_id) REFERENCES SettlementCurrency(id)
        ON DELETE RESTRICT
);

-- 6. Создание транзакционных таблиц
CREATE TABLE IF NOT EXISTS UserPaymentFee (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trans_type INT NOT NULL,
    account_id INT NOT NULL,
    ratio NUMERIC(5, 5) CHECK (ratio >= 0),
    absolute NUMERIC(15, 2) CHECK (absolute >= 0),
    CHECK (ratio > 0 OR absolute > 0),
    FOREIGN KEY (trans_type) REFERENCES TransactionType(id),
    FOREIGN KEY (account_id) REFERENCES MainAccount(id)
);

CREATE TABLE IF NOT EXISTS Transactions (
    id SERIAL PRIMARY KEY,
    recipient_acc INT NOT NULL,
    sender_acc INT NOT NULL,
    type_id INT NOT NULL,
    date_transaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    currency VARCHAR(20) NOT NULL,
    comission_id INT,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    CHECK (sender_acc != recipient_acc),
    FOREIGN KEY (recipient_acc) REFERENCES MainAccount(id),
    FOREIGN KEY (sender_acc) REFERENCES MainAccount(id),
    FOREIGN KEY (type_id) REFERENCES TransactionType(id),
    FOREIGN KEY (comission_id) REFERENCES UserPaymentFee(id)
);

CREATE TABLE IF NOT EXISTS SettlementPaymentTransactions (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fee_id INT NOT NULL,    
    CONSTRAINT fk_payment_fee 
        FOREIGN KEY (fee_id) REFERENCES EntityPaymentFee(id)
        ON DELETE RESTRICT,
    account_id INT NOT NULL,    
    CONSTRAINT fk_account_id
        FOREIGN KEY (account_id) REFERENCES SettlementAccount(id)
        ON DELETE RESTRICT,
    primary_amount DECIMAL(11, 3) NOT NULL DEFAULT 0,
    type_id INT NOT NULL,    
    CONSTRAINT fk_type_id
        FOREIGN KEY (type_id ) REFERENCES TransactionType(id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS CreditTransactions (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fee_id INT NOT NULL,    
    CONSTRAINT fk_payment_fee 
        FOREIGN KEY (fee_id) REFERENCES EntityPaymentFee(id)
        ON DELETE RESTRICT,
    account_id INT NOT NULL,    
    CONSTRAINT fk_account_id
        FOREIGN KEY (account_id) REFERENCES CreditAccount(id)
        ON DELETE RESTRICT,
    primary_amount DECIMAL(11, 3) NOT NULL DEFAULT 0,
    type_id INT NOT NULL,    
    CONSTRAINT fk_type_id
        FOREIGN KEY (type_id ) REFERENCES TransactionType(id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS ExchangeRate (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    settlement_id INT NOT NULL,    
    ratio DECIMAL(15, 5) NOT NULL DEFAULT 0,
    CONSTRAINT fk_settlement_id
        FOREIGN KEY (settlement_id) REFERENCES LegalEntity(id)
        ON DELETE RESTRICT,
    currency_from INT NOT NULL,    
    CONSTRAINT money_pairs 
        CHECK (currency_from != currency_to),
    CONSTRAINT fk_currency_from
        FOREIGN KEY (currency_from) REFERENCES SettlementCurrency(id)
        ON DELETE RESTRICT,
    is_current BOOLEAN DEFAULT FALSE,
    currency_to INT NOT NULL,    
    CONSTRAINT fk_currency_to
        FOREIGN KEY (currency_to) REFERENCES SettlementCurrency(id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS SettlementExchangeTransactions (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fee_id INT NOT NULL,    
    CONSTRAINT fk_payment_fee 
        FOREIGN KEY (fee_id) REFERENCES EntityPaymentFee(id)
        ON DELETE RESTRICT,
    rate_id INT NOT NULL,    
    CONSTRAINT fk_rate_id 
        FOREIGN KEY (rate_id) REFERENCES ExchangeRate(id)
        ON DELETE RESTRICT,
    account_id INT NOT NULL,    
    CONSTRAINT fk_account_id
        FOREIGN KEY (account_id) REFERENCES ForeignCurrencyAccount(id)
        ON DELETE RESTRICT,
    primary_amount DECIMAL(11, 3) NOT NULL DEFAULT 0,
    type_id INT NOT NULL,    
    CONSTRAINT fk_type_id
        FOREIGN KEY (type_id ) REFERENCES TransactionType(id)
        ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS StockTransactions (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stock_id INT NOT NULL,
    account_id INT NOT NULL, 
    operation_type_id INT NOT NULL,
    value NUMERIC(20, 4) NOT NULL,
    stock_price_id INT, 
    FOREIGN KEY (stock_id) REFERENCES Stocks(id),
    FOREIGN KEY (account_id) REFERENCES SavingsAccount(id),
    FOREIGN KEY (operation_type_id) REFERENCES StockTransactionTypes(id),
    FOREIGN KEY (stock_price_id) REFERENCES StockPrices(id)
);

CREATE TABLE IF NOT EXISTS UserStock (
    id SERIAL PRIMARY KEY,
    transact_id INT NOT NULL,
    brock_acc_num INT NOT NULL,
    FOREIGN KEY (transact_id) REFERENCES StockTransactions(id),
    FOREIGN KEY (brock_acc_num) REFERENCES BrokerageAccount(id)
);


-- 7. Создание индексов
CREATE INDEX idx_individual_passport ON Individual(passport_series, passport_nums);
CREATE INDEX idx_individual_inn ON Individual(INN);
CREATE INDEX idx_individual_phone ON Individual(phone_num);
CREATE INDEX idx_individual_name ON Individual(surname, first_name, patronymic);

CREATE INDEX idx_transactions_sender_date ON Transactions(sender_acc, date_transaction DESC);
CREATE INDEX idx_transactions_recipient_date ON Transactions(recipient_acc, date_transaction DESC);
CREATE INDEX idx_transactions_date ON Transactions(date_transaction DESC);
CREATE INDEX idx_transactions_type ON Transactions(type_id);
CREATE INDEX idx_transactions_type_date ON Transactions(type_id, date_transaction DESC);

CREATE INDEX idx_debit_main_account ON DebutAccount(main_account_num);
CREATE INDEX idx_brokerage_main_account ON BrokerageAccount(main_account_num);
CREATE INDEX idx_loan_main_account ON LoanAccount(main_account_num);

CREATE INDEX idx_fee_account_type ON UserPaymentFee(account_id, trans_type);

CREATE INDEX idx_stocktypes_name ON StockTypes(type_name);
CREATE INDEX idx_stocks_ticker ON Stocks(ticker);
CREATE INDEX idx_stocks_type ON Stocks(stock_type);
CREATE INDEX idx_stocks_registered ON Stocks(registered_at);

CREATE INDEX idx_currency_ticker ON UserCurrency(ticker);
CREATE INDEX idx_currency_country ON UserCurrency(country);

CREATE INDEX idx_savings_main_account ON SavingsAccount(main_account_num);
CREATE INDEX idx_savings_currency ON SavingsAccount(currency_id);
CREATE INDEX idx_savings_agreement ON SavingsAccount(agreement_num);
CREATE INDEX idx_savings_created ON SavingsAccount(created_at);

CREATE INDEX idx_stock_prices_stock_date ON StockPrices(stock_id, updated_at DESC);
CREATE INDEX idx_stock_prices_date ON StockPrices(updated_at DESC);
CREATE INDEX idx_stock_prices_price ON StockPrices(price) WHERE price > 0;

CREATE INDEX idx_stock_transactions_account_date ON StockTransactions(account_id, created_at DESC);
CREATE INDEX idx_stock_transactions_stock_date ON StockTransactions(stock_id, created_at DESC);

CREATE INDEX idx_user_stock_account_stock ON UserStock(brock_acc_num, transact_id);

CREATE INDEX idx_payment_transactions_account_created ON SettlementPaymentTransactions(account_id, created_at DESC);
CREATE INDEX idx_credit_transactions_account_created ON CreditTransactions(account_id, created_at DESC);
CREATE INDEX idx_exchange_transactions_account_created ON SettlementExchangeTransactions(account_id, created_at DESC);

CREATE INDEX idx_payment_transactions_type_created ON SettlementPaymentTransactions(type_id, created_at);
CREATE INDEX idx_credit_transactions_type_created ON CreditTransactions(type_id, created_at);

CREATE INDEX idx_payment_transactions_created ON SettlementPaymentTransactions(created_at);
CREATE INDEX idx_credit_transactions_created ON CreditTransactions(created_at);

CREATE INDEX idx_account_settlement_currency ON SettlementAccount(settlement_id, currency_id);
CREATE INDEX idx_foreign_account_settlement_currency ON ForeignCurrencyAccount(settlement_id, currency_id);
CREATE INDEX idx_credit_account_settlement_currency ON CreditAccount(settlement_id, currency_id);

CREATE INDEX idx_account_status ON SettlementAccount(status) WHERE status != 'active';
CREATE INDEX idx_foreign_account_status ON ForeignCurrencyAccount(status) WHERE status != 'active';

CREATE INDEX idx_exchange_rate_pair_date ON ExchangeRate(currency_from, currency_to, created_at DESC);
CREATE UNIQUE INDEX idx_exchange_rate_current ON ExchangeRate(currency_from, currency_to) WHERE is_current = TRUE;
CREATE INDEX idx_exchange_rate_currency_from ON ExchangeRate(currency_from, created_at DESC);
CREATE INDEX idx_exchange_rate_currency_to ON ExchangeRate(currency_to, created_at DESC);

CREATE INDEX idx_legal_entity_inn ON LegalEntity(INN);
CREATE INDEX idx_legal_entity_name ON LegalEntity(name);

CREATE INDEX idx_payment_fee_settlement_type ON EntityPaymentFee(settlement_id, type_id);
CREATE INDEX idx_payment_fee_type ON EntityPaymentFee(type_id);

CREATE INDEX idx_exchange_transactions_created ON SettlementExchangeTransactions(created_at);

-- =========================================================================
-- СИДДЕР ДАННЫХ С ПРОВЕРКОЙ СУЩЕСТВОВАНИЯ ДАННЫХ (PostgreSQL)
-- * В этом блоке PL/pgSQL используются переменные, объявленные через DECLARE.
-- * Это корректно работает в Go-миграторе.
-- =========================================================================

DO $$
DECLARE
    -- Определяем константы для дат внутри блока PL/pgSQL
    start_date CONSTANT TIMESTAMP := '2024-01-01 00:00:00';
    end_date CONSTANT TIMESTAMP := '2025-01-01 00:00:00';
BEGIN

    -- Проверка: если в одной из первых справочных таблиц (TransactionType) нет данных,
    -- то запускаем сидирование всего остального.
    IF NOT EXISTS (SELECT 1 FROM TransactionType) THEN

        RAISE NOTICE '--- НАЧАЛО СИДИРОВАНИЯ БАЗЫ ДАННЫХ ---';

        --------------------------------------------------------------------------------
        -- 1. Справочные таблицы
        --------------------------------------------------------------------------------

        -- TransactionType (Типы транзакций)
        INSERT INTO TransactionType (name) VALUES
        ('Пополнение счета'),
        ('Перевод другому клиенту'),
        ('Оплата услуг'),
        ('Снятие наличных'),
        ('Покупка ценной бумаги'),
        ('Продажа ценной бумаги');

        -- SettlementCurrency (Валюта расчетов)
        INSERT INTO SettlementCurrency (ticker, country) VALUES
        ('RUB', 'Россия'),
        ('USD', 'США'),
        ('EUR', 'Еврозона'),
        ('CNY', 'Китай'),
        ('GBP', 'Великобритания');

        -- StockTypes (Типы акций)
        INSERT INTO StockTypes (type_name) VALUES
        ('Акция'),
        ('Облигация'),
        ('Фонд ETF'),
        ('Опцион');

        -- StockTransactionTypes (Типы операций с акциями)
        INSERT INTO StockTransactionTypes (operation_name) VALUES
        ('Покупка'),
        ('Продажа');

        -- UserCurrency (Валюта пользователя)
        INSERT INTO UserCurrency (ticker, country) VALUES
        ('RUB', 'Россия'),
        ('USD', 'США'),
        ('EUR', 'Еврозона');

        --------------------------------------------------------------------------------
        -- 2. Основные сущности (50 Физ. лиц, 10 Юр. лиц)
        --------------------------------------------------------------------------------

        -- Individual (50 записей)
        INSERT INTO Individual (first_name, surname, patronymic, INN, passport_series, passport_nums, phone_num, password)
        SELECT
            CASE WHEN i % 5 = 0 THEN 'Иван' WHEN i % 5 = 1 THEN 'Мария' WHEN i % 5 = 2 THEN 'Петр' WHEN i % 5 = 3 THEN 'Анна' ELSE 'Дмитрий' END || i,
            CASE WHEN i % 5 = 0 THEN 'Иванов' WHEN i % 5 = 1 THEN 'Смирнова' WHEN i % 5 = 2 THEN 'Козлов' WHEN i % 5 = 3 THEN 'Попова' ELSE 'Соколов' END || i,
            CASE WHEN i % 3 = 0 THEN 'Алексеевич' WHEN i % 3 = 1 THEN 'Сергеевна' ELSE 'Владимирович' END,
            LPAD((100000000000 + i * 123)::text, 12, '0'), -- INN (12 digits)
            (i % 90) + 1000, -- Passport Series
            (100000 + i * 456), -- Passport Nums
            '+79' || LPAD((900000000 + i * 1000)::text, 9, '0'), -- Phone
            MD5('pass' || i)
        FROM GENERATE_SERIES(1, 50) AS i;

        -- LegalEntity (10 записей)
        INSERT INTO LegalEntity (name, INN, owner_id)
        SELECT
            'ООО "' || CASE WHEN i % 2 = 0 THEN 'Инвест' ELSE 'Торг' END || 'Плюс' || i || '"',
            LPAD((500000000000 + i * 987)::text, 12, '0'), -- INN
            (i % 50) + 1
        FROM GENERATE_SERIES(1, 10) AS i;

        --------------------------------------------------------------------------------
        -- 3. Акционные инструменты (20 записей)
        --------------------------------------------------------------------------------

        -- Stocks (20 записей)
        INSERT INTO Stocks (stock_type, ticker)
        SELECT
            (i % 3) + 1,
            CASE i % 4
                WHEN 0 THEN 'SBER'
                WHEN 1 THEN 'YNDX'
                WHEN 2 THEN 'GAZP'
                ELSE 'VTBR'
            END || i
        FROM GENERATE_SERIES(1, 20) AS i;

        -- StockPrices (100 записей - 5 цен для каждой акции)
        INSERT INTO StockPrices (stock_id, price, updated_at)
        SELECT
            s.id,
            (RANDOM() * 5000 + 10)::NUMERIC(20, 4),
            NOW() - ('30 days'::interval * RANDOM()) AS updated_at
        FROM Stocks s, GENERATE_SERIES(1, 5) AS i
        ORDER BY s.id, updated_at;

        --------------------------------------------------------------------------------
        -- 4. Основные счета и их конфигурация
        --------------------------------------------------------------------------------

        -- MainAccount (50 записей, 1 на каждого физ. лица)
        INSERT INTO MainAccount (user_id, BIC, agreement_num)
        SELECT
            i,
            LPAD(((1000000000 + i * 1) % 999999999)::text, 11, '0'),
            1000 + i
        FROM GENERATE_SERIES(1, 50) AS i;

        -- UserPaymentFee (150 записей - 3 типа комиссии на каждого из 50 MainAccount)
        INSERT INTO UserPaymentFee (trans_type, account_id, ratio, absolute)
        SELECT
            (i % 3) + 1,
            (i % 50) + 1,
            (RANDOM() * 0.005)::NUMERIC(5, 5),
            (CASE WHEN RANDOM() > 0.5 THEN 100 ELSE 0 END)::NUMERIC(15, 2)
        FROM GENERATE_SERIES(1, 150) AS i;

        -- EntityPaymentFee (30 записей - 3 типа комиссии на каждого из 10 LegalEntity)
        INSERT INTO EntityPaymentFee (settlement_id, ratio, absolute, type_id)
        SELECT
            (i % 10) + 1,
            (RANDOM() * 0.01)::DECIMAL(15, 5),
            (RANDOM() * 500)::DECIMAL(15, 2),
            (i % 3) + 1
        FROM GENERATE_SERIES(1, 30) AS i;

        --------------------------------------------------------------------------------
        -- 5. Специализированные счета Физ. лиц (50 записей каждого типа)
        --------------------------------------------------------------------------------

        -- DebutAccount
        INSERT INTO DebutAccount (BIC, agreement_num, main_account_num, currency_id, card_num, card_validity, CVV, amount)
        SELECT
            LPAD(((2000000000 + i * 1) % 999999999)::text, 11, '0'),
            2000 + i,
            i,
            (i % 3) + 1,
            LPAD((5000000000000000 + i * 100)::text, 16, '0'),
            (i % 12) + 2026,
            (i % 899) + 100,
            (RANDOM() * 100000 + 500)::DECIMAL(15, 2)
        FROM GENERATE_SERIES(1, 50) AS i;

        -- BrokerageAccount
        INSERT INTO BrokerageAccount (BIC, agreement_num, main_account_num, depository, tax_resident_status, depot_account_num)
        SELECT
            LPAD(((3000000000 + i * 1) % 999999999)::text, 11, '0'),
            3000 + i,
            i,
            'Депо' || (i % 5) + 1,
            CASE WHEN i % 10 = 0 THEN 'non-resident' ELSE 'resident' END::resident_status,
            500000 + i
        FROM GENERATE_SERIES(1, 50) AS i;

        -- LoanAccount
        INSERT INTO LoanAccount (BIC, agreement_num, main_account_num, currency_id, card_num, card_validity, CVV, bet, repayment_period, limit_amount)
        SELECT
            LPAD(((4000000000 + i * 1) % 999999999)::text, 11, '0'),
            4000 + i,
            i,
            1,
            LPAD((6000000000000000 + i * 100)::text, 16, '0'),
            (i % 12) + 2026,
            (i % 899) + 100,
            (RANDOM() * 10 + 5)::DECIMAL(5, 2),
            (i % 24) + 12,
            (RANDOM() * 500000 + 10000)::DECIMAL(15, 2)
        FROM GENERATE_SERIES(1, 50) AS i;

        -- SavingsAccount
        INSERT INTO SavingsAccount (bic, agreement_num, main_account_num, currency_id, bet, amount)
        SELECT
            LPAD(((5000000000 + i * 1) % 999999999)::text, 11, '0'),
            5000 + i,
            i,
            (i % 3) + 1,
            (RANDOM() * 7 + 1)::DECIMAL(5, 2),
            (RANDOM() * 50000 + 1000)::DECIMAL(15, 2)
        FROM GENERATE_SERIES(1, 50) AS i;


        --------------------------------------------------------------------------------
        -- 6. Специализированные счета Юр. лиц (10 записей каждого типа)
        --------------------------------------------------------------------------------

        -- SettlementAccount
        INSERT INTO SettlementAccount (settlement_id, currency_id, balance, status)
        SELECT
            i,
            1, -- RUB
            (RANDOM() * 1000000 + 50000)::DECIMAL(15, 2),
            CASE WHEN i % 10 = 0 THEN 'closed'::ACCOUNT_STATUS ELSE 'active'::ACCOUNT_STATUS END
        FROM GENERATE_SERIES(1, 10) AS i;

        -- ForeignCurrencyAccount
        INSERT INTO ForeignCurrencyAccount (settlement_id, currency_id, balance, status)
        SELECT
            i,
            (i % 2) + 2, -- USD(2) или EUR(3)
            (RANDOM() * 50000 + 100)::DECIMAL(15, 2),
            'active'::ACCOUNT_STATUS
        FROM GENERATE_SERIES(1, 10) AS i;

        -- CreditAccount
        INSERT INTO CreditAccount (settlement_id, currency_id, balance, status)
        SELECT
            i,
            1, -- RUB
            (RANDOM() * 200000 + 10000)::DECIMAL(15, 2),
            'active'::ACCOUNT_STATUS
        FROM GENERATE_SERIES(1, 10) AS i;


        --------------------------------------------------------------------------------
        -- 7. Курсы обмена (ExchangeRate)
        --------------------------------------------------------------------------------

        -- ExchangeRate (RUB/USD)
        INSERT INTO ExchangeRate (settlement_id, ratio, currency_from, currency_to, is_current, created_at)
        SELECT 
            (i % 5) + 1, 
            (70 + RANDOM() * 30)::DECIMAL(15, 5), 
            1, 2, 
            (i = 1), -- Только i=1 будет TRUE, остальные FALSE
            NOW() - (i * '1 day'::interval)
        FROM GENERATE_SERIES(1, 5) AS i;

        -- RUB -> EUR (1 -> 3). Генерируем 5 записей, только 1-я активна
        INSERT INTO ExchangeRate (settlement_id, ratio, currency_from, currency_to, is_current, created_at)
        SELECT 
            (i % 5) + 1, 
            (80 + RANDOM() * 30)::DECIMAL(15, 5), 
            1, 3, 
            (i = 1), 
            NOW() - (i * '1 day'::interval)
        FROM GENERATE_SERIES(1, 5) AS i;

        --------------------------------------------------------------------------------
        -- 8. Транзакционные данные (более 2000 записей)
        --------------------------------------------------------------------------------

        -- Transactions (Транзакции Физ. лиц - 2000 записей)
        INSERT INTO Transactions (recipient_acc, sender_acc, type_id, currency, comission_id, amount, date_transaction)
        SELECT
            (i % 50) + 1,
            ((i + 1) % 50) + 1,
            (i % 3) + 1,
            CASE (i % 3) WHEN 0 THEN 'RUB' WHEN 1 THEN 'USD' ELSE 'EUR' END,
            (SELECT id FROM UserPaymentFee ORDER BY RANDOM() LIMIT 1),
            (RANDOM() * 5000 + 100)::DECIMAL(15, 2),
            start_date + (i * '1 minute'::interval)
        FROM GENERATE_SERIES(1, 2000) AS i;


        -- SettlementPaymentTransactions (Платежи Юр. лиц - 500 записей)
        INSERT INTO SettlementPaymentTransactions (fee_id, account_id, primary_amount, type_id, created_at)
        SELECT
            (i % 30) + 1,
            (i % 10) + 1,
            (RANDOM() * 50000 + 1000)::DECIMAL(11, 3),
            (i % 3) + 1,
            start_date + (i * '2 minutes'::interval)
        FROM GENERATE_SERIES(1, 500) AS i;


        -- CreditTransactions (Кредитные транзакции Юр. лиц - 200 записей)
        INSERT INTO CreditTransactions (fee_id, account_id, primary_amount, type_id, created_at)
        SELECT
            (i % 30) + 1,
            (i % 10) + 1,
            (RANDOM() * 10000 + 100)::DECIMAL(11, 3),
            (i % 3) + 1,
            start_date + (i * '5 minutes'::interval)
        FROM GENERATE_SERIES(1, 200) AS i;


        -- SettlementExchangeTransactions (Обменные транзакции Юр. лиц - 100 записей)
        INSERT INTO SettlementExchangeTransactions (fee_id, rate_id, account_id, primary_amount, type_id, created_at)
        SELECT
            (i % 30) + 1,
            (i % 10) + 1,
            (i % 10) + 1,
            (RANDOM() * 1000 + 10)::DECIMAL(11, 3),
            (i % 3) + 1,
            start_date + (i * '10 minutes'::interval)
        FROM GENERATE_SERIES(1, 100) AS i;


        -- StockTransactions (Транзакции с акциями - 400 записей: покупка/продажа)
        INSERT INTO StockTransactions (stock_id, account_id, operation_type_id, value, stock_price_id, created_at)
        SELECT
            (i % 20) + 1,
            (i % 50) + 1,
            (i % 2) + 1,
            (RANDOM() * 100 + 1)::NUMERIC(20, 4),
            (SELECT id FROM StockPrices WHERE stock_id = (i % 20) + 1 ORDER BY updated_at DESC LIMIT 1),
            start_date + (i * '15 minutes'::interval)
        FROM GENERATE_SERIES(1, 400) AS i;


        -- UserStock (Владение акциями)
        INSERT INTO UserStock (transact_id, brock_acc_num)
        SELECT
            st.id,
            st.account_id
        FROM StockTransactions st
        WHERE st.operation_type_id = 1; -- Только покупки

        RAISE NOTICE '--- СИДИРОВАНИЕ УСПЕШНО ЗАВЕРШЕНО ---';

    ELSE
        RAISE NOTICE '--- СИДИРОВАНИЕ ПРОПУЩЕНО: ДАННЫЕ УЖЕ СУЩЕСТВУЮТ ---';
    END IF;

END
$$;