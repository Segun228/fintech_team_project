CREATE TABLE IF NOT EXISTS StockTypes (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Stocks (
    id SERIAL PRIMARY KEY,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stock_type INT NOT NULL,
    ticker VARCHAR(10) UNIQUE NOT NULL,
    FOREIGN KEY (stock_type) REFERENCES StockTypes(id)
);

CREATE TABLE IF NOT EXISTS UserCurrency (
    id SERIAL PRIMARY KEY,
    ticker VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS SavingsAccount (
    account_number SERIAL PRIMARY KEY,
    bic VARCHAR(11) UNIQUE NOT NULL,
    agreement_num INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    main_account_num INT NOT NULL,
    currency_id INT NOT NULL,
    bet INT,
    amount INT,
    FOREIGN KEY (currency_id) REFERENCES UserCurrency(id),
    FOREIGN KEY (main_account_num) REFERENCES MainAccount(account_number)
);

CREATE TABLE IF NOT EXISTS UserStock (
    id SERIAL PRIMARY KEY,
    transact_id INT NOT NULL,
    brock_acc_num INT NOT NULL,
    FOREIGN KEY (transact_id) REFERENCES StockTransactions(id),
    FOREIGN KEY (brock_acc_num) REFERENCES BrokerageAccount(account_number)
);

CREATE TABLE IF NOT EXISTS StockPrices (
    id SERIAL PRIMARY KEY,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stock_id INT NOT NULL,
    price NUMERIC(20, 4) NOT NULL,
    FOREIGN KEY (stock_id) REFERENCES Stocks(id)
);

CREATE TABLE IF NOT EXISTS StockTransactions (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stock_id INT NOT NULL,
    operation_type_id INT NOT NULL,
    value NUMERIC(20, 4) NOT NULL,
    stock_price_id DECIMAL(10, 3),
    FOREIGN KEY (stock_id) REFERENCES Stocks(id),
    FOREIGN KEY (account_id) REFERENCES SavingsAccount(account_number),
    FOREIGN KEY (operation_type_id) REFERENCES StockTransactionTypes(id),
    FOREIGN KEY (stock_price_id) REFERENCES StockPrices(id)
);

CREATE TABLE IF NOT EXISTS StockTransactionTypes (
    id SERIAL PRIMARY KEY,
    operation_name VARCHAR(255) NOT NULL
);

CREATE INDEX CONCURRENTLY idx_stocktypes_name ON StockTypes(type_name);

CREATE INDEX CONCURRENTLY idx_stocks_ticker ON Stocks(ticker);
CREATE INDEX CONCURRENTLY idx_stocks_type ON Stocks(stock_type);
CREATE INDEX CONCURRENTLY idx_stocks_registered ON Stocks(registered_at);

CREATE INDEX CONCURRENTLY idx_currency_ticker ON UserCurrency(ticker);
CREATE INDEX CONCURRENTLY idx_currency_country ON UserCurrency(country);

CREATE INDEX CONCURRENTLY idx_savings_main_account ON SavingsAccount(main_account_num);
CREATE INDEX CONCURRENTLY idx_savings_currency ON SavingsAccount(currency_id);
CREATE INDEX CONCURRENTLY idx_savings_agreement ON SavingsAccount(agreement_num);
CREATE INDEX CONCURRENTLY idx_savings_created ON SavingsAccount(created_at);

CREATE INDEX CONCURRENTLY idx_stock_prices_stock_date ON StockPrices(stock_id, updated_at DESC);
CREATE INDEX CONCURRENTLY idx_stock_prices_date ON StockPrices(updated_at DESC);
CREATE INDEX CONCURRENTLY idx_stock_prices_price ON StockPrices(price) WHERE price > 0;



CREATE INDEX CONCURRENTLY idx_stock_transactions_account_date ON StockTransactions(savings_account_id, created_at DESC);

CREATE INDEX CONCURRENTLY idx_stock_prices_stock_date ON StockPrices(stock_id, updated_at DESC);

CREATE INDEX CONCURRENTLY idx_stocks_ticker ON Stocks(ticker);

CREATE INDEX CONCURRENTLY idx_stock_transactions_stock_date ON StockTransactions(stock_id, created_at DESC);

CREATE INDEX CONCURRENTLY idx_user_stock_account_stock ON UserStock(brock_acc_num, stock_id);


